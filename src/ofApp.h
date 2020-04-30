#pragma once

#include "ofxiOS.h"

#define FINMAX 2
#define BBOX_RESOLUTION 32
#define RENDER_THRESHOLD 2*10000

class Label{
public:
    Label() = default;
    Label(int _id, string _name){
        id = _id;
        name = _name;
    }
    int id;
    string name;
};

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
    ofRectangle getYoloFormat(ofRectangle _r, float _width, float _height, int _resolution);
    bool saveYoloFormat(ofRectangle _r);
    bool dataAugmentation(char _foldername[]);
    ofImage resizeImages(ofImage _image, int _resizeResolution);
    ofRectangle changeLocation(ofRectangle _r, int _resizeResolution);

    bool isTouching[FINMAX];
    ofPoint touchLoc[FINMAX];
    
    ofVideoGrabber camera;
    ofImage image_capture;
    ofImage image_480px;
    ofImage image_bbox;

    ofImage image_1080px;
    
    unsigned char pix_bbox[BBOX_RESOLUTION*BBOX_RESOLUTION];
    unsigned char pix_bbox_prev[BBOX_RESOLUTION*BBOX_RESOLUTION];
    double pix_bbox_dif;
    
    ofRectangle r_camera_window;
    ofRectangle r_bbox;
    
    Label label_now;
    string foldername;
    
    ofTrueTypeFont lato_semibold;
    ofTrueTypeFont lato_semibold_small;
    ofTrueTypeFont lato_bold;
    ofRectangle b_rendering;
    bool flg_rendering = false;
    
    int countRendering = 0;
    
    ofDirectory dir;
    
    ofRectangle b_DA;
    string str_log;
    //bool flg_runDA = false;
};


