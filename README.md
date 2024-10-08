# GAME: GrAspable Media Entertainment
This repository contains the GAMA models for the GAME project (Additional components are required).

## Requirements
1. [ROS Noetic Installation](http://wiki.ros.org/noetic/Installation/Ubuntu)
2. [OptiTrack Motion Capture System](https://optitrack.com/) & [Motive Software](https://optitrack.com/software/)
3. [OptiTrack ROS Communication Repository](https://github.com/IE-Robotics-Lab/optitrack_ros_communication)

## Abstract
This research explores the development of a Tangible User Interface (TUI) designed for gaming purposes. GAME (GrAspable Media Entertainment) is an innovative project that enables users to physically interact with digital gaming elements, bridging the gap between the physical and virtual worlds. This is achieved through the integration of multiple technologies, including a motion capture system (Optitrack), a short-throw projector (Optoma UHD35STx), and an agent-based simulation software (GAMA). GAME supports interactive gameplay (e.g., Player vs. Player, Player vs. AI), offering a more immersive and versatile gaming experience than conventional screen-based implementations. Furthermore, GAME leverages blockchain technology, specifically the Ripple protocol (i.e., XRPL), to facilitate gameplay actions such as store progress checkpoints, secure in-game transactions, and track player scores. The addition of the blockchain component allows easy game customization, and enhances the overall gaming experience. In conclusion, the combination of tangible user interfaces with blockchain technology can pave the way for future developments in important fields such as education, training, and entertainment where novel interaction methods are paramount.

## Demo Video
[![IE Robotics Lab YouTube](https://img.youtube.com/vi/o1hVKjgDzAk/0.jpg)](https://www.youtube.com/watch?v=o1hVKjgDzAk)

## Figures  
![system](https://github.com/user-attachments/assets/99881605-034d-4a50-afc4-571f6a3740fd)  
*Figure 1: A) System architecture of the base TUI game set-up. 1. Sensing: The system uses a motion capture camera system (OptiTrack) to track the position and orientation of the Universal Marker Holders (UMHs) by using its proprietary software (Motive 3D). 2. Processing: A server running the Robot Operating System (ROS) serves as an intermediary between the physical and digital information by processing the motion capture data and sending it to an agent-based simulation (i.e., GAMA) software via UDP. 3. Actuation: GAMA software simulates the game environment and takes the motion capture data to control the game elements which the GAMA software then projects onto the game board. B) Real setup used for testing GAME.*  

![umh](https://github.com/user-attachments/assets/83a74ed9-6e77-4c0c-8f4a-4303f85f219d)  
*Figure 2: A) 3D-printed Universal Marker Holder (UMH) with a unique configuration of retroreflective markers. Each marker is attached to an M4 screw connected to the body of the UMH. B) Dimensions of the UMH.*
