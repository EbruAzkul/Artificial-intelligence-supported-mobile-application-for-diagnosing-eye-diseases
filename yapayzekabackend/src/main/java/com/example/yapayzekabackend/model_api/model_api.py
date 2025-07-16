import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model
from flask import Flask, request, jsonify
from PIL import Image
import os
import io

app = Flask(__name__)

MODEL_PATH = r"C:\Users\HUAWEI\PycharmProjects\yapay_zeka_eğitim\eye_disease_model_complete.h5"

LABELS = ["cataract", "diabetic_retinopathy", "glaucoma", "normal"]
INPUT_SIZE = (256, 256)

try:
    print("[MODEL] Model yükleniyor...")
    model = load_model(MODEL_PATH)
    print("[MODEL] Model başarıyla yüklendi!")

    # Modeli özetini göster
    model.summary()

except Exception as e:
    print(f"[MODEL] Hata: {e}")
    raise

def preprocess_image(file_stream):
    try:
        img_bytes = file_stream.read()
        img = Image.open(io.BytesIO(img_bytes)).convert('RGB')
        img = img.resize(INPUT_SIZE)

        # MobileNetV2 için preprocessing
        img_array = np.array(img)
        img_array = tf.keras.applications.mobilenet_v2.preprocess_input(img_array)
        img_array = np.expand_dims(img_array, axis=0)
        return img_array
    except Exception as e:
        print("[GÖRÜNTÜ] Hata:", str(e))
        raise

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'Lütfen bir görüntü dosyası yükleyin'}), 400

    try:
        file = request.files['file']
        processed_img = preprocess_image(file.stream)

        predictions = model.predict(processed_img)[0]
        probabilities = tf.nn.softmax(predictions).numpy()

        predicted_class = LABELS[np.argmax(probabilities)]
        confidence = float(np.max(probabilities)) * 100  # Yüzde olarak

        return jsonify({
            'predicted_class': predicted_class,
            'confidence': confidence,
            'all_probabilities': {lab: float(prob) * 100 for lab, prob in zip(LABELS, probabilities)}
        })

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e), 'trace': traceback.format_exc()}), 500


if __name__ == '__main__':
    print("[API] Başlatılıyor: http://localhost:5001")
    app.run(host='0.0.0.0', port=5001, debug=True)