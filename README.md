# Training Own Object Detection Model with YOLO

In this project, a custom YOLO model was trained to detect toy cars in real-time.

## Used Technologies

- Python 3.10
- Docker
- Label Studio
- YOLO from Ultralytics
- Windows PowerShell
- OpenCV

## Implemetation Workflow

### 1. Data Collection
- Captured photos of toy cars against various backgrounds, under different conditions and in multiple combinations to make the model robust.

### 2. Annotation with Docker & Label Studio
- Ran Label Studio inside a Docker container mapped to a local port.
- Annotated all images and exported the annotations in YOLO format.

### 3. Automated Dataset Splitting
- Wrote a custom Windows PowerShell (`ps1`) script to automatically match images with their corresponding label files and split them into `train` and `val` directories.
- Configured the required `data.yaml` file for YOLO training.

### 4. Training & Real-Time Inference
- Fine-tuned a YOLO model on the custom dataset.
- Developed a Python script to run real-time inference on a live webcam stream to detect the toy cars dynamically.

### 5. Iteration & Model Improvement
- Since the initial accuracy was lower than expected, collected and labeled additional images to improve model performance. In the second training phase, the model was trained on the larger dataset.