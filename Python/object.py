#object detection: is a computer vision where a model answers two questions:
#1) what object is present? ----->classification
#2) where the object is ? ---> localization

#terminal ma garne kammmmmmmmmmm
#py --list
#py -3.13 -m venv venv
#cd venv
#ls
#cd Scrips
#./activate
#cd..
#cd..
# pip install -r requirements.txt


#YOLO= You Only Look Once
#it is used for real-time object detection models
#modern yolo version are widely used for:
#object detection
#tracking
#post elimination etc

#yolo basic working
#Image ---> Yolo ----> feature extraction ---->prediction ---> boxes,classes,c --->NMS---->final results

#NMS: Non -maximum suppression
#it keeps the strongest detection and removes highly overlapping weaker detections

#IOU: intersection over union to measure how much two boxes overlap.
# NMS uses IOU
# if overlap is very high , the detector may decide:
   #these probably represents the same objects.