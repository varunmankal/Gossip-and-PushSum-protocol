##########################
######## PROJECT 2 ####### 
#### GOSSIP SIMULATOR ####
############3#############

#Group members#
1) Raheen Mazgaonkar, UFID: 47144316
2) Varun Mankal, UFID: 04827615

#Implementation Details:#

Genserver module of elixir was used for implementation of actors. All communication is assumed to be asynchronous.

The general flow of the project is as follows:
1)	First n nodes are created (For 2D and imperfect 2D we generate m nodes where m is the nearest perfect square of n)
2)	Next, we calculate the neighbor of each node based on the topology and send each node its neighbor list. To avoid failure, we first check if the node is alive before sending it the message.
3)	Once this is done we start initial the timer and send the first message to random node in the network.
4)	A process monitor is set to check how many processes have converged (here, convergence causes termination).
5)	Once convergence is met the monitor exits and we can calculate the total time taken for convergence.

#Gossip Protocol Implementation#
1)	Whenever a message receives a message, it increments its counters and actives the periodic send function.
2)	Periodic send keeps on sending messages to its randomly selected neighbor.
3)	A node it terminated when it has heard the message 10 times.
Convergence Criteria: We consider our protocol to have converged when at least 90% of the nodes have heard the message 10 times.

#Push-Sum Protocol Implementation#
1)	When a node receives a message, it adds the value of the s and w received in the message to its own s and w values.
2)	It sends half of this s and w value to any of its randomly selected neighbor and keeps half for its self. To avoid failure, we first check if the node is alive before sending it the message.
3)	This process continues till the s/w ratio of the node hasn’t terminated for 3 consecutive times. 
Converge Criteria: It was observed by the time the counter for anyone node reaches 3, the message has reached every node in the network at least node.

# LARGEST NETWORK #

A) GOSSIP
  i) Full:
  ii) Imperfect 2D:
  iii) 2D:
  iv) Line:
  

B) PUSH SUM
  i) Full: 10000 
  ii) Imperfect 2D: 30000 time: 23078
  iii) 2D: 5000
  iv) Line: 5000