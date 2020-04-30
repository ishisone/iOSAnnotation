#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    ofxAccelerometer.setup();
    ofSetOrientation(OF_ORIENTATION_DEFAULT);
    camera.initGrabber(1920, 1080);
    
    r_camera_window.set(0, 120, ofGetWidth(), ofGetWidth());
    
    cout << ofGetWidth() << "  " << ofGetHeight() << endl;
    cout << camera.getWidth() << "  " << camera.getHeight() << endl;
    
    for(int i = 0; i < FINMAX; i++){
        isTouching[i] = false;
    }
    
    label_now.id = 0;
    label_now.name = "sample";
    foldername = ofGetTimestampString();
    
    //fonts
    ofTrueTypeFont::setGlobalDpi(72);
    lato_semibold.load("Lato-Semibold.ttf", 15);
    lato_semibold.setLineHeight(23);
    lato_semibold.setLetterSpacing(1.0);
    
    lato_semibold_small.load("Lato-Semibold.ttf", 10);
    lato_semibold_small.setLineHeight(12);
    lato_semibold_small.setLetterSpacing(1.0);
    
    lato_bold.load("Lato-Bold.ttf", 16);
    lato_bold.setLineHeight(25);
    lato_bold.setLetterSpacing(1.0);
    
    b_rendering.set(18, 40 + lato_bold.getLineHeight()-lato_bold.getSize(), ofGetWidth()/2, lato_bold.getSize());
    
    ofBackground(10, 10, 10);
    
    str_log = "Log: ";
//    countRendering =401;
}

//--------------------------------------------------------------
void ofApp::update(){
    camera.update();
    if( camera.isFrameNew() ){
        image_capture.setFromPixels(camera.getPixels());
        image_480px = image_capture;
        image_480px.crop( camera.getWidth()/2 - 480/2, camera.getHeight()/2 - 480/2 , 480, 480);
        
        image_1080px = image_capture;
        image_1080px.crop( camera.getWidth()/2 - 1080/2, camera.getHeight()/2 - 1080/2 , 1080, 1080);
        
        if( isTouching[0] && isTouching[1] ){
            
            // cropping
            image_bbox = image_480px;
            float scale = 480/320.0;
            image_bbox.crop(r_bbox.x*scale, (r_bbox.y - r_camera_window.y)*scale, r_bbox.width*scale, r_bbox.height*scale);
            image_bbox.resize(BBOX_RESOLUTION, BBOX_RESOLUTION);
            image_bbox.setImageType(OF_IMAGE_GRAYSCALE);
            
            pix_bbox_dif = 0;
            for(int i = 0; i < BBOX_RESOLUTION*BBOX_RESOLUTION; i++){
                pix_bbox[i] = image_bbox.getPixels()[i];
                pix_bbox_dif += abs(pix_bbox_prev[i] - pix_bbox[i]);
            }
            cout << pix_bbox_dif << endl;

            if( flg_rendering ){
                if( pix_bbox_dif > RENDER_THRESHOLD ){
                    countRendering++;
                    saveYoloFormat(r_bbox);
                    cout << "render!!!" << endl;
                    
                    // if bbox pixels are more than rendering threshold, rendered image store previous image.
                    for(int i = 0; i < BBOX_RESOLUTION*BBOX_RESOLUTION; i++){
                        pix_bbox_prev[i] = pix_bbox[i];
                    }
                }
            }
        }
        else{
            r_bbox.set(0, 0, 0, 0);
        }
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofSetColor(255, 255, 255);
    
    if(camera.isFrameNew()){
        image_480px.draw(r_camera_window);
    
        // fonts & meseages
        ofSetColor(180);
        string str_label, str_rendering;
        str_label += "Selected label : [" + ofToString(label_now.id) + "] " + label_now.name + "\n";
        lato_bold.drawString(str_label, 18, 40);
        str_rendering += "Rendering count: ";
        
        if( flg_rendering ){
            str_rendering += ofToString(countRendering) + "\n";
            //        str_rendering += "The total: " + ofToString(countRendering*3);
        }
        else{
            ofSetColor(170, 0, 0);
            str_rendering += "OFF";
        }
        lato_bold.drawString(str_rendering, 18, 40+lato_bold.getLineHeight());
    
        ofSetColor(50);
        string app_name;
        app_name = "ios annotation";
        lato_semibold.drawString(app_name, ofGetWidth()/2 - (int)app_name.length()/2*7, ofGetHeight() - 5);
        
        // drowing line & bbox
        ofSetColor(200, 200, 200, 200);
        ofFill();
        for(int i = 0; i < FINMAX; i++){
            ofDrawLine(touchLoc[i].x, r_camera_window.y, touchLoc[i].x, r_camera_window.getMaxY());
            ofDrawLine(0, touchLoc[i].y, ofGetWidth(), touchLoc[i].y);
        }
        
        if( isTouching[0] && isTouching[1] ){
            ofSetColor(0, 0, 150, 70);
            ofDrawRectangle(r_bbox);
            
            // drawing bbox image
            for( int i = 0; i < BBOX_RESOLUTION; i++){
                for( int j = 0; j < BBOX_RESOLUTION; j++){
                    ofSetColor(pix_bbox[j+i*BBOX_RESOLUTION]);
                    ofDrawRectangle(j, ofGetHeight()-BBOX_RESOLUTION+i, 1, 1);
                }
            }
        }
        
        // DAのボタンとかもろもろ
        b_DA.set(ofGetWidth()/2-90, 460, 180, 35);
        ofSetColor(130);
        ofNoFill();
        ofDrawRectangle(b_DA);
        string strDA = "Data Augmentaion";
        lato_semibold.drawString(strDA, b_DA.getCenter().x - (int)strDA.length()*4.2, b_DA.getBottom()-10);
        
        // Logとか一応書いてみる
        ofSetColor(80);
        lato_semibold_small.drawString(str_log, 10, b_DA.getBottom()+17);
        
    }
    /*
    // DA処理中
    if( flg_runDA == true ){
        cout << "DA" << endl;
        ofSetColor(0, 0, 0);
        ofFill();
        ofDrawRectangle(0, 0, ofGetWidth(), ofGetHeight());
        ofSetColor(200);
        lato_bold.drawString("Data Augmentation system is running...", 7, ofGetHeight()/2);
    }
     */
}

//--------------------------------------------------------------
void ofApp::exit(){

}

ofRectangle ofApp::getYoloFormat(ofRectangle _r, float _width, float _height, int _resolution)
{
    float dw, dh;
    if( _resolution == 480 ){
         dw = dh = 0;
    }
    else{
         dw = (_resolution/1.5 - _width)/2;
         dh = (_resolution/1.5 - _height)/2;
    }
    float x = ((_r.x - r_camera_window.x) + dw) / (_width + dw*2);
    float y = ((_r.y - r_camera_window.y) + dh)/(_height + dh*2);
    float w = _r.width/(_width + dw*2);
    float h = _r.height/(_height + dh*2);
    
    ofRectangle r_return(x, y, w, h);
    return r_return;
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    if( touch.id < FINMAX && r_camera_window.inside(touch.x, touch.y)){
        isTouching[touch.id] = true;
        touchLoc[touch.id].set(touch.x, touch.y);
        r_bbox.setX( touchLoc[0].x );
        r_bbox.setY( touchLoc[0].y );
        r_bbox.setWidth( touchLoc[1].x - r_bbox.getX() );
        r_bbox.setHeight( touchLoc[1].y - r_bbox.getY() );
        r_bbox.standardize();
    }
    
    if( b_rendering.inside(touch.x, touch.y)){
        flg_rendering = !flg_rendering;
    }
    
    //ここにofDirectoryのテストしてみる
    if( touch.id == 0 && b_DA.inside(touch.x, touch.y) ){
        //bool flg_runDA = true;
        //draw();
//        char name[] = "2020-02-04-02-37-14-587";
        char name[] = {};
        foldername.copy(name, foldername.length());
        if( dataAugmentation(name) ){
            str_log += "Exported in " + foldername + ". /  " + ofToString(countRendering * 3) + " in total." + "\n           ";
            cout << "finished DA !" << endl;
            foldername = ofGetTimestampString();
//            foldername = "2020-02-04-02-37-14-587";
            countRendering = 0;
//            flg_runDA = false;
        }
        else{
            str_log += "can not export.\n";
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    if( touch.id < FINMAX ){
        float Y;
        if( touch.y < r_camera_window.y ) Y = r_camera_window.y;
        else if( r_camera_window.getMaxY() < touch.y ) Y = r_camera_window.getMaxY();
        else Y = touch.y;
        touchLoc[touch.id].set(touch.x, Y);
        r_bbox.setX( touchLoc[0].x );
        r_bbox.setY( touchLoc[0].y );
        r_bbox.setWidth( touchLoc[1].x - r_bbox.getX() );
        r_bbox.setHeight( touchLoc[1].y - r_bbox.getY() );
        r_bbox.standardize();
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    touchLoc[touch.id].set(0, 0);
    isTouching[touch.id] = false;
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

bool ofApp::saveYoloFormat(ofRectangle _r)
{
    string filename;
    filename = ofGetTimestampString();
    
    
    ofSaveImage(image_1080px.getPixels(), ofxiOSGetDocumentsDirectory() + "/" + foldername + "/" + filename + ".jpg" , OF_IMAGE_QUALITY_BEST);
    
    int resolution[1] = {1080};
    for(int i = 0; i < 1; i++){
        ofBuffer buf;
        string str;
        ofRectangle r_yolo = getYoloFormat(_r, r_camera_window.width, r_camera_window.height, resolution[i]);
        str += ofToString(label_now.id) + " " +
        ofToString(r_yolo.getCenter().x) + " " +
        ofToString(r_yolo.getCenter().y) + " " +
        ofToString(r_yolo.width) + " " +
        ofToString(r_yolo.height) + "\n";
        buf.append(str);
        
        ofBufferToFile(ofxiOSGetDocumentsDirectory() + "/" + foldername + "/" + filename + ".txt", buf);
    }
}


bool ofApp::dataAugmentation(char _foldername[]){
    dir.open(ofxiOSGetDocumentsDirectory() + ofToString(_foldername));
    cout << _foldername << endl;
    if( dir.isDirectory() ){
        cout << "can open" << endl;
    
        cout << dir.path() << endl;
        cout << dir.listDir() << endl;
        cout << dir.getName(0) << endl;
        cout << dir.getName(1) << endl;
        cout << dir.getPath(1) << endl;
        dir.close();
        
        int count = 0;
        int directory_size = dir.listDir(dir.getOriginalDirectory());
        for( int i = 0; i < directory_size/2; i++){
            ofImage importedImage;
            ofBuffer buf_txt;
            string filename_jpg = dir.getName(i*2);
            string filename_txt = dir.getName(i*2+1);
            count++;
            
            importedImage.load( dir.getPath(i*2) );
            buf_txt = ofBufferFromFile( dir.getPath(i*2+1) );
            
            //cout << ofToString(buf_txt) << endl;
        
            string str = ofToString(buf_txt);
            
            // 取り込んだtxtを変数として格納
            vector<string> result;
            string tmp_str;
            string sub_str;
            tmp_str = str;
            for(int j = 0; j < 5; j++ ){
                sub_str = tmp_str;
                if( j == 4 ){
                    result.push_back(tmp_str);
                }
                else{
                    string a = sub_str.erase(sub_str.find_first_of(" "), sub_str.size());
                    result.push_back(a);
                    tmp_str.erase(0,tmp_str.find_first_of(" ")+1);
                }
            }
            int id;
            id = ofToInt(result[0]);
            ofRectangle r_imporedBBox;
            r_imporedBBox.set(ofToFloat(result[1]), ofToFloat(result[2]), ofToFloat(result[3]), ofToFloat(result[4]));
            //cout << result[0] + "," + result[1] + "," +result[2] + "," +result[3] + "," +result[4] << endl;
            
            // 画像と位置情報の再計算
            
            ofRectangle changedBBox;
            
            int resolution[3] = {480, 720, 1080};
            for( int j = 0; j < 3; j++ ){
                ofImage tmp_image = resizeImages(importedImage, resolution[j]);
                
                if( resolution[j] == 1080 ){
                    ofSaveImage( tmp_image.getPixels(), dir.getOriginalDirectory() + filename_jpg ,OF_IMAGE_QUALITY_BEST );
                }
                else{
                    ofSaveImage( tmp_image.getPixels(), dir.getOriginalDirectory() + ofToString(resolution[j]) + "px" + filename_jpg ,OF_IMAGE_QUALITY_BEST );
                    
                    ofBuffer buf;
                    changedBBox = changeLocation(r_imporedBBox, resolution[j]);
                    string tmp;
                    tmp += ofToString(id) + " " + ofToString(changedBBox.x) + " " + ofToString(changedBBox.y) + " " + ofToString(changedBBox.width) + " " + ofToString(changedBBox.height) + "\n";
                    buf.append(tmp);
                    ofBufferToFile(dir.getOriginalDirectory() + ofToString(resolution[j]) + "px" + filename_txt, buf);
                }
            }
        }
        return true;
    }
    else{
        cout << "can not use" << endl;
        return false;
    }
}

ofImage ofApp::resizeImages(ofImage _image, int _resizeResolution){
    if( _resizeResolution >= 1080 ){
        _image.resize(480, 480);
        return _image;
    }
    else if( _resizeResolution > 480){
        _image.crop((1080-_resizeResolution)/2, (1080-_resizeResolution)/2, _resizeResolution, _resizeResolution);
        _image.resize(480, 480);
        return _image;
    }
    else{
        _image.crop((1080-_resizeResolution)/2, (1080-_resizeResolution)/2, _resizeResolution, _resizeResolution);
        return _image;
    }
}

ofRectangle ofApp::changeLocation(ofRectangle _r, int _resizeResolution){
    float x = (_r.x*1080 - (1080-_resizeResolution)/2) / _resizeResolution;
    float y = (_r.y*1080 - (1080-_resizeResolution)/2) / _resizeResolution;
    float w = (1080 * _r.width) / _resizeResolution;
    float h = (1080 * _r.height) / _resizeResolution;
    ofRectangle r_return(x, y, w, h);
    return r_return;
}
//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
