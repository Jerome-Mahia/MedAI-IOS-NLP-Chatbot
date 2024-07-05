import tensorflow as tf

# Load the existing model
model = tf.keras.models.load_model('chatbotmodel.h5')

# Convert the model to the TensorFlow Lite format without quantization
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the model to disk
with open('chatbotmodel.tflite', 'wb') as f:
    f.write(tflite_model)

print("Model converted to TFLite successfully.")