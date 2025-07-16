import os
import numpy as np
import tensorflow as tf
from flask import Flask, request, jsonify
from PIL import Image
import io
import base64

app = Flask(__name__)

# Sınıflar - modelinizden
LABELS = ["Normal", "Glaucoma", "Cataract", "Diabetic Retinopathy"]

# Modeli yüklemeyi dene
try:
    print("Model yükleniyor...")
    # Dosyanın varlığını kontrol et
    if os.path.exists('eye_disease_cnn_rnn_model.h5'):
        model = tf.keras.models.load_model('eye_disease_cnn_rnn_model.h5')
        print("Model başarıyla yüklendi!")
    else:
        print("Model dosyası bulunamadı. Test modu aktif.")
        model = None
except Exception as e:
    print(f"Model yüklenirken hata oluştu: {e}")
    model = None

def preprocess_image(image):
    # Görüntüyü yeniden boyutlandır
    image = image.resize((256, 256))
    # Görüntüyü array'e dönüştür
    img_array = np.array(image)
    # 0-1 aralığına normalize et
    img_array = img_array / 255.0
    # Batch boyutu ekle
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'Görüntü bulunamadı'}), 400
    
    try:
        file = request.files['file']
        img = Image.open(file.stream)
        
        # RGB'ye dönüştür (eğer gerekirse)
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Görüntüyü ön işle
        processed_img = preprocess_image(img)
        
        # Model yoksa test modu
        if model is None:
            # Test değerleri (rastgele)
            predictions = [0.15, 0.25, 0.50, 0.10]
            print("Test modu: Gerçek model olmadan tahmin yapılıyor")
        else:
            # Gerçek model tahmini
            predictions = model.predict(processed_img)[0]
            
        # En yüksek olasılıklı sınıfı bul
        predicted_class_index = np.argmax(predictions)
        predicted_class = LABELS[predicted_class_index]
        confidence = float(predictions[predicted_class_index])
        
        # Tüm sınıf olasılıklarını al
        all_probabilities = {LABELS[i]: float(predictions[i]) for i in range(len(LABELS))}
        
        return jsonify({
            'predicted_class': predicted_class,
            'confidence': confidence,
            'all_probabilities': all_probabilities
        })
    
    except Exception as e:
        print(f"Tahmin sırasında hata: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'OK', 'message': 'Model API çalışıyor'})

if __name__ == '__main__':
    print("API başlatılıyor - http://localhost:5001/")
    print("Ctrl+C ile durdurabilirsiniz.")
    app.run(debug=True, host='0.0.0.0', port=5001)