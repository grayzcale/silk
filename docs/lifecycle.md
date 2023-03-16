---
sidebar_position: 2
---

# The SILK Lifecycle

The SILK lifecycle is designed to simplify the overall control of package usage and stage execution.

The initialization phase is initiated by a single bootstrapper script that is responsible for supplying the framework with any specific dependencies. Any script that attempts to retrieve and access the primary singleton class using `Silk.Wait` during the *uninitialized phase* will yield until the initialization is completed. The server initialization phase takes precedence over the client initialization phase, i.e. if the client requests initialization data before the server reaches the initialized state, the client must yield until the server is ready to provide the data.

Configuration will only be provided once through the server intializer script. When the client requests data for initialization, it aims to make a seamless *local copy* of the initialized singleton class that exists on the server. In this way, when the data is recieved by the client, some information may be lost since it may not be visible to the client.

Just like with normal server-sided scripts, client scripts begin execution immediately after the client reaches the initialized state. Additionally, any communication between the client and server, including during the client initialization phase, only takes place with the server in its intialized state. This approach gurantees that the server is always in a ready state whenever the client communicates.

##### Diagram of the SILK lifecycle:

<img src="/silk/lifecycle.png" width="80%"/>