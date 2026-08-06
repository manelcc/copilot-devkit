# Chapter 14: Deepfakes

## Core Idea
Deepfakes are AI-generated synthetic media (video, images, audio) that convincingly replace or reenact a person's appearance, voice, or behavior. Three technical modes — Replacement, Re-enactment, and Editing — each use different GAN/feature-engineering pipelines. Key technical components include facial landmark detection (OpenCV, Dlib, MTCNN), 3D Morphable Models (3DMM), and FACS (Facial Action Coding System).

## Frameworks Introduced

- **Three Deepfake Modes**:
  - **Replacement**: swap one person's face with another's in a video/image; fully replaces identity.
  - **Re-enactment**: transfer expressions/movements from a source face to a target face; identity of target is preserved.
  - **Editing**: modify specific facial attributes (age, expression, makeup, gaze) without full face replacement.
  - Decision rule: use replacement for impersonation; re-enactment for puppetry/dub; editing for attribute control.

- **High-Level Deepfake Workflow (Re-enactment)**:
  1. Detect and align faces in source and target videos.
  2. Extract facial landmarks (68 keypoints per frame).
  3. Estimate 3D face parameters via 3DMM or FACS codes.
  4. Render source expression onto target geometry.
  5. Blend rendered face back onto target video frame.
  6. Post-process for temporal consistency.

- **Facial Landmark Detection**:
  - **OpenCV**: Haar cascade-based face detection + LBF landmark model; fast, lower accuracy.
  - **Dlib**: HOG-based face detection + shape predictor (68 landmarks); industry standard accuracy.
  - **MTCNN**: Multi-Task Cascaded CNN; best accuracy, handles occlusion and multiple scales.
  - When to use: MTCNN for highest quality; OpenCV for speed; Dlib for balanced accuracy/speed.

- **FACS (Facial Action Coding System)**:
  - What: psychologist Paul Ekman's system for describing all possible human facial expressions using 44 "Action Units" (AUs).
  - How: decompose any facial expression into a weighted combination of AUs.
  - Deepfake use: extract FACS codes from source face → apply AU weights to target face → transfer expression.

- **3DMM (3D Morphable Model)**:
  - What: statistical model of 3D face shape and appearance; parametrize any face as a vector of shape/texture coefficients.
  - How: fit 3DMM to each video frame → extract shape/expression/identity parameters → render onto target.
  - Key property: 3DMM separates identity (face geometry) from expression (deformation) → enables cross-person expression transfer.

- **Re-enactment via Pix2Pix**:
  - Practical approach: extract facial landmark maps from source → use Pix2Pix to translate landmark map → target face image.
  - Dataset preparation: source video frames + OpenPose/Dlib landmarks → (landmark, face) pairs for Pix2Pix training.
  - Training: Pix2Pix G maps landmark image → face image; D discriminates real face from generated.

## Key Concepts

- **Face Swapping**: replace one identity's face with another's; requires blending edges seamlessly
- **Temporal Consistency**: generated frames must be coherent across time; naive frame-by-frame generation produces flickering
- **Facial Landmarks**: 68 characteristic keypoints per face (eyes, nose, mouth, jawline) — the skeleton for face alignment and tracking
- **Action Units (AUs)**: FACS building blocks — e.g., AU1+AU4+AU15 = sad expression; AU6+AU12 = Duchenne smile
- **3DMM parameters**: shape vector (identity), expression vector, texture vector — fit to each frame via optimization
- **Face Alignment**: rotating and scaling detected face to a canonical orientation before processing
- **Occlusion**: hands, glasses, or other objects blocking parts of the face — main technical challenge for landmark detection
- **Off-the-shelf implementations**: FaceSwap (GitHub, open source), DeepFaceLab, SimSwap — ready-to-use deepfake pipelines

## Mental Models

- FACS AUs = "facial muscle activations" — any expression is a linear combination of these 44 primitive muscle movements.
- 3DMM = "a parametric face template" — any face in the world can be described as offsets from an average face shape and texture.
- Re-enactment: "borrow the expression, keep the person" — extract expression from source, apply to target geometry, render.
- MTCNN = "hierarchical face detection" — first finds face regions, then aligns, then detects landmarks at each scale.

## Anti-patterns

- **Using OpenCV landmarks for high-stakes reenactment**: insufficient accuracy for subtle expressions; use Dlib or MTCNN.
- **No temporal smoothing**: frame-by-frame generation produces flickering artifacts; apply exponential moving average to landmark positions.
- **Deepfakes without ethical disclosure**: non-consensual deepfakes are illegal in many jurisdictions; always disclose synthetic media.
- **Ignoring occlusion in landmark detection**: undetected occlusions produce wrong landmark positions → corrupted expression transfer.

## Code Examples

```python
import cv2
import dlib

# Dlib facial landmark detection (68 landmarks)
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")

def detect_landmarks(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = detector(gray, 1)
    if not faces:
        return None
    shape = predictor(gray, faces[0])
    # Convert to numpy: 68×2 array of (x,y) coordinates
    return [(shape.part(i).x, shape.part(i).y) for i in range(68)]

landmarks = detect_landmarks(frame)
```
- **What it demonstrates**: Dlib-based 68-point facial landmark detection — the input to most deepfake pipelines.

```python
from mtcnn import MTCNN
import cv2

# MTCNN: highest-accuracy face + landmark detection
detector = MTCNN()

def detect_mtcnn(image_path):
    img = cv2.cvtColor(cv2.imread(image_path), cv2.COLOR_BGR2RGB)
    results = detector.detect_faces(img)
    # Returns: [{'box': [x,y,w,h], 'confidence': 0.99,
    #             'keypoints': {'left_eye': (x,y), 'right_eye': (x,y),
    #                           'nose': (x,y), 'mouth_left': (x,y), 'mouth_right': (x,y)}}]
    return results
```
- **What it demonstrates**: MTCNN returns bounding boxes, confidence scores, and 5 keypoints — best accuracy for multi-scale face detection.

## Worked Example

**Re-enacting Obama's facial movements using Pix2Pix:**

1. **Dataset preparation**:
   - Source: Obama video → extract frames → detect Dlib landmarks → draw landmark skeleton on blank canvas
   - Target: same frames → face images
   - Creates (landmark_image, face_image) pairs for Pix2Pix training

2. **Training Pix2Pix**:
   - G (U-Net): landmark skeleton image → synthesized Obama face
   - D (PatchGAN): classifies (landmark, face) pairs as real or generated
   - Loss: L1(generated_face, real_face) × 100 + adversarial loss

3. **Re-enactment at inference**:
   - Take source person's facial landmarks from new video
   - Feed landmark skeleton to trained G → generates Obama's face with source expressions
   - Blend back onto target video frame

Results and limitations:
- Works well for frontal faces and moderate expression changes
- Struggles with: large head rotations > 30°, occlusions, unusual lighting
- Temporal flicker from frame-by-frame generation requires post-processing smoothing

## Key Takeaways

1. Three modes — Replacement, Re-enactment, Editing — each require different GAN architectures and input representations.
2. Facial landmarks (Dlib: 68 points, MTCNN: 5 points) are the universal interface between face detection and expression transfer.
3. FACS Action Units provide a language-like decomposition of facial expressions — combining AUs reconstructs any human emotion.
4. 3DMMs separate identity from expression — enabling cross-person expression transfer without face swapping.
5. Ethical and technical challenges are inseparable: deepfakes can be malicious (impersonation, non-consensual) and must be disclosed; temporal consistency is the key technical challenge.

## Connects To

- **Ch 12**: GAN architecture (DC-GAN, Progressive GAN) underpins face generation
- **Ch 13**: Pix2Pix used directly for face reenactment; CycleGAN for unpaired face editing
- **Ch 10**: hallucination/authenticity detection is the defensive counterpart to deepfake generation
