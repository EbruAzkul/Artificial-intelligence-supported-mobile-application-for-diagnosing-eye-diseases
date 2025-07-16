import os
import cv2
import random
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import tensorflow as tf
from PIL import Image
from tensorflow import keras
from tensorflow.keras.models import Sequential, model_from_json
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import classification_report, confusion_matrix
from tensorflow.keras import layers, callbacks
import warnings

warnings.filterwarnings('ignore')

print("GPU Kullanılabilir mi: ", tf.config.list_physical_devices('GPU'))

dataset_dir = 'C:\\Users\\HUAWEI\\PycharmProjects\\yapay_zeka_eğitim\\dataset' 

class_names = [d for d in os.listdir(dataset_dir) if os.path.isdir(os.path.join(dataset_dir, d))]
print("Sınıf İsimleri:", class_names)
num_classes = len(class_names)
print("Sınıf Sayısı:", num_classes)

train_dir = os.path.join(dataset_dir, 'train')
val_dir = os.path.join(dataset_dir, 'validation')
test_dir = os.path.join(dataset_dir, 'test')

if not os.path.exists(train_dir):
    os.makedirs(train_dir)
    for class_name in class_names:
        os.makedirs(os.path.join(train_dir, class_name), exist_ok=True)

if not os.path.exists(val_dir):
    os.makedirs(val_dir)
    for class_name in class_names:
        os.makedirs(os.path.join(val_dir, class_name), exist_ok=True)

if not os.path.exists(test_dir):
    os.makedirs(test_dir)
    for class_name in class_names:
        os.makedirs(os.path.join(test_dir, class_name), exist_ok=True)


def split_data(src_dir, train_dir, val_dir, test_dir, train_ratio=0.7, val_ratio=0.15, test_ratio=0.15):
   
    train_files = sum([len(os.listdir(os.path.join(train_dir, c))) for c in class_names if
                       os.path.exists(os.path.join(train_dir, c))])
    val_files = sum(
        [len(os.listdir(os.path.join(val_dir, c))) for c in class_names if os.path.exists(os.path.join(val_dir, c))])
    test_files = sum(
        [len(os.listdir(os.path.join(test_dir, c))) for c in class_names if os.path.exists(os.path.join(test_dir, c))])

    if train_files > 0 and val_files > 0 and test_files > 0:
        print(f"Veri seti zaten bölünmüş. Train: {train_files}, Validation: {val_files}, Test: {test_files}")
        return

    for class_name in class_names:
        class_src_dir = os.path.join(src_dir, class_name)

        if not os.path.exists(class_src_dir):
            print(f"Uyarı: {class_src_dir} dizini bulunamadı.")
            continue

        class_train_dir = os.path.join(train_dir, class_name)
        class_val_dir = os.path.join(val_dir, class_name)
        class_test_dir = os.path.join(test_dir, class_name)

        os.makedirs(class_train_dir, exist_ok=True)
        os.makedirs(class_val_dir, exist_ok=True)
        os.makedirs(class_test_dir, exist_ok=True)

        all_files = [f for f in os.listdir(class_src_dir) if os.path.isfile(os.path.join(class_src_dir, f))]

        random.shuffle(all_files)

        train_end = int(len(all_files) * train_ratio)
        val_end = train_end + int(len(all_files) * val_ratio)

        train_files = all_files[:train_end]
        val_files = all_files[train_end:val_end]
        test_files = all_files[val_end:]

        import shutil
        for f in train_files:
            shutil.copy2(os.path.join(class_src_dir, f), os.path.join(class_train_dir, f))

        for f in val_files:
            shutil.copy2(os.path.join(class_src_dir, f), os.path.join(class_val_dir, f))

        for f in test_files:
            shutil.copy2(os.path.join(class_src_dir, f), os.path.join(class_test_dir, f))

        print(f"{class_name} sınıfı - Train: {len(train_files)}, Validation: {len(val_files)}, Test: {len(test_files)}")


try:
    split_data(dataset_dir, train_dir, val_dir, test_dir)
except Exception as e:
    print(f"Veri bölme işlemi sırasında hata: {e}")
    print("Mevcut veri seti yapısı kullanılacak.")


def visualize_images(path, target_size=(256, 256), num_images=5):
    
    image_filenames = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f))]

    if not image_filenames:
        raise ValueError(f"'{path}' yolunda görüntü bulunamadı")

    selected_images = random.sample(image_filenames, min(num_images, len(image_filenames)))

    fig, axes = plt.subplots(1, min(num_images, len(selected_images)), figsize=(15, 3), facecolor='white')

    if len(selected_images) == 1:
        axes = [axes]

    for i, image_filename in enumerate(selected_images):
        image_path = os.path.join(path, image_filename)
        image = Image.open(image_path)
        image = image.resize(target_size)

        axes[i].imshow(image)
        axes[i].axis('off')
        axes[i].set_title(image_filename) 

    plt.tight_layout()
    plt.show()


try:
    for class_name in class_names:
        class_train_dir = os.path.join(train_dir, class_name)
        if os.path.exists(class_train_dir) and os.listdir(class_train_dir):
            print(f"{class_name} eğitim örnekleri:")
            visualize_images(class_train_dir, num_images=5)
except Exception as e:
    print(f"Görüntüleri görselleştirirken hata: {e}")

image_size = (256, 256)
batch_size = 32

train_datagen = ImageDataGenerator(
    preprocessing_function=tf.keras.applications.mobilenet_v2.preprocess_input,
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    horizontal_flip=True,
    zoom_range=0.2
)

val_test_datagen = ImageDataGenerator(
    preprocessing_function=tf.keras.applications.mobilenet_v2.preprocess_input
)

train_generator = train_datagen.flow_from_directory(
    train_dir,
    target_size=image_size,
    batch_size=batch_size,
    class_mode='sparse',  
    shuffle=True
)

validation_generator = val_test_datagen.flow_from_directory(
    val_dir,
    target_size=image_size,
    batch_size=batch_size,
    class_mode='sparse',
    shuffle=False  
)

test_generator = val_test_datagen.flow_from_directory(
    test_dir,
    target_size=image_size,
    batch_size=batch_size,
    class_mode='sparse',
    shuffle=False  
)

print("Sınıf İndeksi Eşlemesi:", train_generator.class_indices)


base_model = tf.keras.applications.MobileNetV2(
    input_shape=(*image_size, 3),
    include_top=False,
    weights='imagenet'
)

base_model.trainable = False

model = Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dropout(0.2),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(num_classes)  # Çıkış katmanı
])


model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
    loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=['accuracy']
)

model.summary()

callbacks_list = [
    callbacks.EarlyStopping(
        monitor='val_loss',
        patience=5,
        restore_best_weights=True
    ),
    callbacks.ModelCheckpoint(
        filepath='best_model.h5',
        monitor='val_accuracy',
        save_best_only=True
    ),
    callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.2,
        patience=3,
        min_lr=1e-6
    )
]

history = model.fit(
    train_generator,
    steps_per_epoch=train_generator.samples // batch_size,
    epochs=20,
    validation_data=validation_generator,
    validation_steps=validation_generator.samples // batch_size,
    callbacks=callbacks_list
)


plt.figure(figsize=(12, 5))
plt.subplot(1, 2, 1)
plt.plot(history.history['accuracy'], label='Eğitim Doğruluğu', marker='o')
plt.plot(history.history['val_accuracy'], label='Doğrulama Doğruluğu', marker='o')
plt.title('Model Doğruluğu')
plt.ylabel('Doğruluk')
plt.xlabel('Epoch')
plt.legend()
plt.grid(True)


plt.subplot(1, 2, 2)
plt.plot(history.history['loss'], label='Eğitim Kaybı', marker='o')
plt.plot(history.history['val_loss'], label='Doğrulama Kaybı', marker='o')
plt.title('Model Kaybı')
plt.ylabel('Kayıp')
plt.xlabel('Epoch')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('training_history.png')
plt.show()


print("Test veri seti üzerinde model değerlendiriliyor...")
test_loss, test_accuracy = model.evaluate(test_generator)
print(f"Test Doğruluğu: {test_accuracy:.4f}")
print(f"Test Kaybı: {test_loss:.4f}")


test_generator.reset()  
y_pred_probs = model.predict(test_generator)
y_pred = np.argmax(y_pred_probs, axis=1)
y_true = test_generator.classes[:len(y_pred)]  

conf_matrix = confusion_matrix(y_true, y_pred)

class_indices = train_generator.class_indices
class_names_ordered = [class_name for class_name, idx in sorted(class_indices.items(), key=lambda x: x[1])]

plt.figure(figsize=(10, 8))
sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='Blues',
            xticklabels=class_names_ordered,
            yticklabels=class_names_ordered)
plt.xlabel('Tahmin Edilen')
plt.ylabel('Gerçek')
plt.title('Confusion Matrix')
plt.tight_layout()
plt.savefig('confusion_matrix.png')
plt.show()

report = classification_report(y_true, y_pred, target_names=class_names_ordered)
print("Sınıflandırma Raporu:")
print(report)


def visualize_predictions(generator, model, num_images=15):

    generator.reset()

    
    batch_x, batch_y = next(generator)

   
    predictions = model.predict(batch_x)
    predicted_classes = np.argmax(predictions, axis=1)

    
    plt.figure(figsize=(16, 12))
    for i in range(min(num_images, len(batch_x))):
        plt.subplot(3, 5, i + 1)
        img = (batch_x[i] * 0.5 + 0.5)  
        plt.imshow(img)

        true_class = class_names_ordered[int(batch_y[i])]
        pred_class = class_names_ordered[predicted_classes[i]]
        confidence = np.max(tf.nn.softmax(predictions[i])) * 100

        title_color = 'green' if true_class == pred_class else 'red'
        plt.title(f"Gerçek: {true_class}\nTahmin: {pred_class}\nGüven: {confidence:.1f}%",
                  color=title_color, fontsize=10)
        plt.axis('off')

    plt.tight_layout()
    plt.savefig('test_predictions.png')
    plt.show()



try:
    visualize_predictions(test_generator, model)
except Exception as e:
    print(f"Tahminleri görselleştirirken hata: {e}")

model_json = model.to_json()
with open("eye_disease_model.json", "w") as json_file:
    json_file.write(model_json)


model.save_weights("eye_disease_model_weights.h5")
print("Model başarıyla kaydedildi.")

model.save("eye_disease_model_complete.h5")
print("Tam model başarıyla kaydedildi.")


def test_custom_image(image_path, model, class_names, target_size=(256, 256)):
  
    img = tf.keras.utils.load_img(image_path, target_size=target_size)

    plt.figure(figsize=(6, 6))
    plt.imshow(img)
    plt.axis('off')
    plt.title("Test Edilecek Görüntü", fontsize=12)
    plt.show()

  
    img_array = tf.keras.utils.img_to_array(img)

    img_array = tf.expand_dims(img_array, 0)
    
    img_array = tf.keras.applications.mobilenet_v2.preprocess_input(img_array)

    predictions = model.predict(img_array)

    probabilities = tf.nn.softmax(predictions)

    plt.figure(figsize=(10, 6))
    plt.bar(class_names, probabilities[0])
    plt.xticks(rotation=45, ha='right')
    plt.ylabel('Olasılık')
    plt.title('Sınıf Olasılıkları')
    plt.tight_layout()
    plt.savefig('class_probabilities.png')
    plt.show()

    predicted_class = class_names[np.argmax(predictions[0])]
    confidence = np.max(probabilities[0]) * 100

    print(f"Tahmin edilen sınıf: {predicted_class}")
    print(f"Güven: {confidence:.2f}%")

    return predicted_class, confidence

