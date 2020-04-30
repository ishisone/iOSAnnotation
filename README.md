# iOSAnnotation

<img src="sample_images/annotation_image.gif" width="500">

# Description

iOSAnnotation is a bounding-box annotation tool by openFrameworks. It is possible to rapidly construct a learning dataset object detection in YOLO format.

# Installation

### 1. Clone iOSAnnotion to your apps/myapps directory.

        $ git clone https://github.com/ishisone/iOSAnnotation.git

### 2. Open a projectGenerator and import ios_annotation. Then click update button.
### 3. Open the project with IDE(Xcode) and just run.

# Usage

1. Press "Rendering OFF" to turn on the rendering.
2. Draw a bounding box like a pinch operation and enclose the object to be registered.
3. When registration is complete, press the "Data Augmentation" button. It takes a bit of time, and when you do the data augmentation, three different images with different image ratios are saved.
4. Download a dataset stored in the application from iTunes.

# Compatibility

- only macOS (tested on High Sierra)
- openFrameworks for ios (0.9.8)
- Xcode 10.1


# License
[MIT License](https://opensource.org/licenses/MIT)
