# CompositeMaterial, a procedural material plugin for Godot

CompositeMaterial provides a workspace for creating procedural hard-surface materials, right inside of the Godot editor, using nodes.

While the node building environment is similar to the visual shader system, CompositeMaterial is higher level and provides a lot of abstractions on top of building regular visual shaders to allow developers and artists to get something running in seconds.

CompositeMaterial is built around the concept of layers and masks.
**Layers** are exactly what you'd expect. They provide a way to stack multiple textures on top of each other. Each layer posesses a set of properties, like color, roughness, metallic and a mask value.
**Masks** are values that determine how visible a layer is at a certain point. These values can be derived from multiple sources, like normal of the surface, a texture or vertex color, and can be manipulated using math, allowing for a very wide range of patterns.
