---
sidebar_position: 2
---

# The SILK Lifecycle

The initialization phase is initiated by a bootstrapper script which performs the necessary functions to provide packages, containers, etc. to the framework. During the uninitialized phase, any script that attempts to access the primary class singleton using `Silk.Wait` will yield until the initialization script completes execution. It's important to note that the server initialization phase takes precedence over the client initialization phase. If the client requests initialization data before the server reaches the initialized state, the client will yield until the server is ready to send data back.

Configuration will only have to be supplied to the server by the developer and not twice over—to the client as well. The client essentially makes a local copy of the initialized singleton class using data returned by the server. Just like with normal server-sided scripts, client scripts begin execution immediately after the client reaches the initialized state. Additionally, all communication between client and server, including during the client initialization phase, occurs within the server intialized state. This approach gurantees that the server is always in a ready, initialized state during all communication. The framework lifecycle is designed to simplify the control of package usage and stage execution for developers.

##### Diagram of the SILK lifecycle:

<img src="/silk/lifecycle.png" width="80%"/>