from ultralytics import YOLO 
import cv2

model = YOLO("the path of the model which was trained using YOLO")

cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()

    if not ret:
        break

    frame = cv2.resize(frame , (640,640))

    result = model(frame , verbose=False , conf=0.7)[0]
    ClassNames = result.names

    for box in result.boxes:
        x1 , y1 , x2 , y2 = map(int , box.xyxy[0].tolist())
        boxID = int(box.cls[0])
        boxType = ClassNames[boxID]

        cv2.rectangle(frame , (x1,y1) , (x2,y2) , color=(255,0,0) , thickness=2)
        cv2.putText(frame , boxType , (x1 , y1-10) , fontFace=cv2.FONT_HERSHEY_SIMPLEX , fontScale=0.6 , color=(255,0,0) , thickness=2)

    cv2.imshow("Window" , frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()