from ultralytics import YOLO

def main():
    model = YOLO("yolo11n.pt")

    model.train(
        data="data.yaml",
        workers=2,
        batch=8,
        imgsz=640,
        device=0,
        epochs=150,
        patience=40,
        project="runs",
        name="Training"
    )
        
if __name__=="__main__":
    main()