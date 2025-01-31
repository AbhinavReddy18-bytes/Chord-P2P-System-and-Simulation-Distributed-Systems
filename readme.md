# Chord: P2P System and Simulation

### Team Members
- **Pavan Vishnu Sai Bestha** (UFID: 3804-3186)
- **Abhinav Reddy Pannala** (UFID: 7031-4901)

## What is Working?
- **Node Creation** - Nodes are successfully created within the network, each represented by an actor.
- **Finger Table Setup** - Each node initializes its finger table, allowing for efficient routing and lookup.
- **Lookup Requests** - Each node is capable of performing lookup requests and routing messages across the network.
- **Average Hops Calculation** - The system computes and outputs the average number of hops required for message delivery.
- **Routing Mechanism** - Correct implementation of node responsibility and message forwarding based on the Chord protocol.

## Largest Network Handled Successfully
The largest network configuration successfully handled by this implementation involved:
- Number of Nodes: 3000
- Number of Requests per Node: 3000

The corresponding output was observed from the macbook terminal:

(base) abhinavreddypannala@Abhinavs-MacBook-Air project3 % ./project3 10 5
Average number of hops required to complete the message routing: 1.38
(base) abhinavreddypannala@Abhinavs-MacBook-Air project3 % 1000 1000
zsh: command not found: 1000
(base) abhinavreddypannala@Abhinavs-MacBook-Air project3 % ./project3 1000 1000
Average number of hops required to complete the message routing: 4.22012
(base) abhinavreddypannala@Abhinavs-MacBook-Air project3 % 3000 2995
zsh: command not found: 3000
(base) abhinavreddypannala@Abhinavs-MacBook-Air project3 % ./project3 3000 2995
Average number of hops required to complete the message routing: 5.16625
(base) abhinavreddypannala@Abhinavs-MacBook-Air project3 % ./project3 3000 2998
Average number of hops required to complete the message routing: 5.16627
(base) abhinavreddypannala@Abhinavs-MacBook-Air project3 % ./project3 3000 3000
Average number of hops required to complete the message routing: 5.57972

- ### These results demonstrate the scalability of the Chord implementation as the average number of hops increases logarithmically with the network size.

## How to Run the Project
To run the project, use the following command format:

./project3 <numNodes> <numRequests>

Where: 
- numNodes: The number of nodes (peers) to be created in the peer-to-peer system.
- numRequests: The number of requests each peer should make.

For example:
```bash
./project3 1000 1000
```
This command will create a Chord system with 1000 nodes, and each node will perform 1000 lookup requests.

