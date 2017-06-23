# Mimsy

This is the animation engine and control software for Mimsy, a new art car for Burning Man 2017.

Mimsy uses the [P3LX framework](https://github.com/heronarts/P3LX) on top of the [LX Studio API](http://lx.studio/api/).



### Installation

Get the latest version of [Processing](https://processing.org/download/).

Open any of the .pde files in the Mimsy directory (which will open the entire project in Processing). 

Click play in the top left corner of the Processing window to run.


### Getting Started

Guide coming soon.

For now the [Dr. Brainlove Getting Started Guide](https://docs.google.com/document/d/18d5SU2r_8FKYEVFae_0DPVjqmHLNQnuAChl41CwmQTM/edit) is a good source for to how to build a new pattern. Some information is Brainlove specific, but the more general information about modulators and parameters in LX is relevant to Mimsy. There have also been LX API changes since that guide was written, but they should be minor fixes.

Mimsy patterns can be found in Patterns.pde (or the patterns tab in the Processing project), and patterns from the [Tree of Ténéré](https://github.com/treeoftenere/Tenere) can be found in TenerePatterns.pde (including a simple tutorial pattern). 

Note that any class in the project that extends LXPattern will be automatically added to the list of available patterns via reflection. This has changed since P2LX, you no longer need to add them yourself.