# CompositeMaterial, a procedural material plugin for Godot

CompositeMaterial provides a workspace for creating procedural hard-surface materials, right inside of the Godot editor, using nodes.

<img width="1382" height="1009" alt="image" src="https://github.com/user-attachments/assets/dda9c924-315a-4353-b9df-deb7e99e809e" />



CompositeMaterial is built around the concept of layers and masks.
**Layers** are exactly what you'd expect. They provide a way to stack multiple textures on top of each other. Each layer posesses a set of properties, like color, roughness, metallic and a mask value.
**Masks** are values that determine how visible a layer is at a certain point. These values can be derived from multiple sources, like normal of the surface, a texture or vertex color, and can be manipulated using math, allowing for a very wide range of patterns.

### Why use this over Godot's VisualShader system?

VisualShader gives you very fine-grained control over your shader. That can be good, but that also means having to set up the complete system behind your procedural material. CompositeMaterial provides fewer, higher-level nodes that utilize more complex systems behind the scenes that you don’t have to worry about as a developer. Where most VisualShader nodes translate directly to a GDShader expression, CompositeMaterial nodes call more complicated functions. Think of masks based on position and surface normal, converting depth maps to normal maps, and HSV tuning. CompositeMaterial is built with a focus on making it easy and quick to create dynamic materials. You cannot do everything you can with shaders, but it’s a lot simpler to use.

## Getting started
Getting started using CompositeMaterial is quite simple. 

If you have the addon installed, you can create a CompositeMaterial resource. I recommend assigning this material to a mesh. If you open this, you'll see a button with the label "Edit" in your inspector. When you press this, the node editor will be opened for you.

You'll see a single output node. You will need to connect layers to this output node to be able to see anything. To do so, press right-click in the editor and select `Add Node...`. From there, select `Layer` and a layer will be created for you. When you connect the layer output to the singular port on the output node, you'll see your material turn purple. Purple is just the default color for any new layer. To change the color, you can connect either a `Texture` node or a `Color Ramp` node to the RGB input of your layer. That's the base of CompositeMaterial. There are a bunch of other nodes for you to try out as well, I recommend screwing around with that. For example, you can plug a `Triplanar Map` node or `UV Transform` node into the UV of your texure.

### Layers

A layer has a number of inputs. Here's a sumamry of what they do:

* RGB: The color of the layer. Takes a Vector3.
* Alpha: The transparency of the layer. Takes a single number.
* Normal: The normal map of the layer. Takes a Vector3.
* Roughness: The roughness value of the layer. Takes a single number.
* Metallic: The metallic value of the layer. Takes a single number.
* Mask: Value that determines where the layer is visible. Takes a single number. There's one caviat with this: For the first/bottom layer (which is the top layer on the output node), this value will always be 1, no matter what you connect to it.
