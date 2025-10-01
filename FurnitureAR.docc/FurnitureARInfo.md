# FurnitureARInfo

##


### Origin of the Idea
The app was created to visualize and decorate empty spaces (apartments or showrooms) before they are furnished. It lets you place 3D models in the real environment and the idea it is that you would be able to save scenes with their location to review and manage them later.

### Technologies
- AR & rendering: ARKit, RealityKit
- Plane detection and focus: FocusEntity (Package to indicate detected planes and placement points)
- 3D models: USDZ
- UI: SwiftUI
- Maps & location: MapKit, CoreLocation
- Architecture: MVM 

### Purpose
AR Decor helps preview furniture and objects in real spaces, speeding up design and decoration decisions with a clear, straightforward experience.

### App Structure

#### FurnitureAR
- Place USDZ models on detected surfaces (visual guidance via FocusEntity).
- Simple interactions to position, adjust, and review objects in the environment.

#### Tabs with Mode Picker
The App has a TabNavigation whose buttons adapt the mode with a picker:

- "Browse" the tab that has 3 buttons focused in the models:
    - Recently: to use the most recently used model
    - Gallery: browse and select available models.
    - Settings: view saved file info and scene location.

- “Scene” mode: shows 3 buttons for:
    - "Save": button with the purpose of saving the current escene
    - "Caragar": button with the purpose of saving the stored scene 
    - “Delete”:  delete previously stored scenes.

#### Settings
- View the scene’s location on the map with MapKit.
- CoreLocation records coordinates and retrieves scenes by place.



> App Status
>
> Full persistence of USDZ models inside scenes is in progress and will be implemented as the next feature.
