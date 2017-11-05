defmodule Project2 do
def main(args) do
   args_list = elem(OptionParser.parse(args),1)
   algorithm = Enum.at(args_list,2) 
   topology =  Enum.at(args_list,1)
   n =  String.to_integer( Enum.at(args_list,0))

  if (algorithm == "push-sum") do
    # create nodes and get pid
    if topology == "line" or topology == "full" do
        node_pid_list = Enum.map(1..n, fn i -> start_ps_link([i,1,0,true]) end) #node_pid_list contains pid of ith node at ith location.
    else
        x = round(Float.ceil(:math.sqrt(n))) ;
        m = round(x*x) ;
        #IO.inspect x
        #IO.inspect m
        node_pid_list = Enum.map(1..m, fn i -> start_ps_link([i,1,0,true]) end)    
    end
  end
    
   
  if algorithm == "gossip" do
    # create nodes and get pid
    if topology == "line" or topology == "full" do
        node_pid_list = Enum.map(1..n, fn i -> start_gs_link() end) #node_pid_list contains pid of ith node at ith location.
    else
        x = round(Float.ceil(:math.sqrt(n))) ;
        m = round(x*x) ;
        node_pid_list = Enum.map(1..m, fn i -> start_gs_link() end)    
    end
  end 

  #create neigbour list of pid => returns list of list 
  neighbours_tuple = create_neighbour_list(n,topology,node_pid_list)

  #send neighbour list to each process

    if topology == "line" or topology == "full" do
        send_neighbour_list(node_pid_list,neighbours_tuple,n)
    else
        send_neighbour_list(node_pid_list,neighbours_tuple,m)
    end

  # send messge to random node
  b = System.system_time(:millisecond);
  send_initial_message("message", hd(Enum.shuffle(node_pid_list)) );
  #send_initial_message("message", hd(node_pid_list) );

  ## new monitoring code ##
    ref_list  = Enum.map(node_pid_list, fn i -> Process.monitor(i) end );
    if (algorithm == "gossip") do 
      monitor_gossip_processes(0,n) 
    else
      monitor_pushsum_processes()
    end

  ## new monitoring code ##

  IO.puts "Convergence time"
  IO.inspect(System.system_time(:millisecond)- b );

end

def monitor_pushsum_processes() do
  receive do
     {:DOWN,ref, :process, pid, msg} -> :ok  
  end
end

def monitor_gossip_processes(counter,n) do
  receive do
     {:DOWN,ref, :process, pid, msg} -> :ok 
  end
  if (counter+1 < n ) do
    #IO.inspect ["Number of dead processes:",counter+1]
    monitor_gossip_processes(counter+1,n) 
  end
end

###############################################################################################################
## start_ps_link() : This function starts process for each node ### 
## Input : Initial state ### 
## Output:  ### 

  def start_ps_link(data_list) do
    {:ok, pid} = GenServer.start_link(PushSum, data_list) ;
    #IO.inspect(pid)
    pid
  end

###############################################################################################################
## start_gs_link() : This function starts process for each node ### 
## Input : Initial state ### 
## Output:  ### 

  def start_gs_link() do
    {:ok, pid} = GenServer.start_link(Gossip2, [0,true]) ;
    #IO.inspect(pid)
    pid
  end

#################################################################################################################
## create_neighbour_list() : This function maps neighbour list to pid neighbour list ### 
## Input : List of List were each ith list contains neighbour of ith element, list of pid ### 
## Output: List of List were each ith list contains pid of neighbour of ith element ### 

  def create_neighbour_list(n,topology,node_pid_list) do

    case topology do
      "full" -> full_nw(node_pid_list) 
      "line" -> line(node_pid_list,n)
      "2D" -> 
        x = round(Float.ceil(:math.sqrt(n))) ;
        m = x*x ;
        twoD(node_pid_list,x,m)
      "imp2D" -> 
        x = round(Float.ceil(:math.sqrt(n))) ;
        m = x*x ;
        imp2D(node_pid_list,x,m)
    end 

  end

#############################################################################################################33
## topology specific function######

  def  full_nw(list) when is_list(list), do: full_nw(list, Enum.count(list), [])
  defp full_nw(list, 0, acc), do: acc
  defp full_nw(list, i, acc) when i > 0, do: full_nw(list, i - 1, [List.delete_at(list, i - 1) | acc])
  
  def  line(list,n) when is_list(list), do: line(list, Enum.count(list), [],n)
  defp line(list, 0, acc,n), do: acc
  defp line(list, i, acc, n) when i == 1 , do: line(list, i - 1, [[Enum.at(list,i)] | acc],n)
  defp line(list, i, acc, n) when i == n, do: line(list, i - 1, [[Enum.at(list,i-2)] | acc],n)
  defp line(list, i, acc, n) , do: line(list, i - 1, [ [Enum.at(list,i-2), Enum.at(list,i)] | acc],n)

  def  twoD(list,n,m) when is_list(list), do: twoD(list, m, [],n,m)
  defp twoD(list, 0, acc, n, m), do: acc
  defp twoD(list, i, acc, n, m) when i == 1, do: twoD(list, i - 1, [[ Enum.at(list,i), Enum.at(list,i+n-1)] | acc], n, m)
  defp twoD(list, i, acc, n, m) when i == n, do: twoD(list, i - 1, [[ Enum.at(list,i-2), Enum.at(list,i+n-1)] | acc], n, m)
  defp twoD(list, i, acc, n, m) when i == m, do: twoD(list, i - 1, [[ Enum.at(list,i-2), Enum.at(list,i-n-1)] | acc], n, m)
  defp twoD(list, i, acc, n, m) when i == (m - n + 1), do: twoD(list, i-1, [[Enum.at(list,i), Enum.at(list,i-n-1)] | acc], n, m)
  defp twoD(list, i, acc, n, m) when i > 1 and i < n , do: twoD(list, i-1, [[Enum.at(list,i), Enum.at(list,i-2), Enum.at(list,i+n-1)] | acc], n, m)
  defp twoD(list, i, acc, n, m) when i > (m - n ) and i<m , do: twoD(list, i-1, [[Enum.at(list,i), Enum.at(list,i-2), Enum.at(list,i-n-1)] | acc], n, m)
  defp twoD(list, i, acc, n, m) when rem(i,n) == 0 , do: twoD(list, i-1, [[Enum.at(list,i-2), Enum.at(list,i+n-1), Enum.at(list,i-n-1)] | acc], n, m)
  defp twoD(list, i, acc, n, m) when rem(i,n) == 1 , do: twoD(list, i-1, [[Enum.at(list,i), Enum.at(list,i+n-1), Enum.at(list,i-n-1)] | acc], n, m)
  defp twoD(list, i, acc, n, m), do: twoD(list, i - 1, [[Enum.at(list,i),Enum.at(list,i-2),Enum.at(list,i+n-1),Enum.at(list,i-n-1)] | acc], n, m)

  def  imp2D(list,n,m) when is_list(list), do: imp2D(list, m,[],n,m)
  defp imp2D(list, 0, acc, n, m), do: acc
  defp imp2D(list, i, acc, n, m) when i == 1, 
    do: imp2D(list, i - 1, [[Enum.at(list,i), Enum.at(list,i+n-1), random_neighbour( list, [Enum.at(list,i), Enum.at(list,i+n-1)],i)] | acc], n, m)
  defp imp2D(list, i, acc, n, m) when i == n, 
    do: imp2D(list, i - 1, [[Enum.at(list,i-2), Enum.at(list,i+n-1), random_neighbour( list, [Enum.at(list,i-2), Enum.at(list,i+n-1)],i )  ] | acc], n, m)
  defp imp2D(list, i, acc, n, m) when i == m, 
    do: imp2D(list, i - 1, [[Enum.at(list,i-2), Enum.at(list,i-n-1), random_neighbour( list , [Enum.at(list,i-2), Enum.at(list,i-n-1)],i ) ] | acc], n, m)
  defp imp2D(list, i, acc, n, m) when i == (m - n + 1), 
    do: imp2D(list, i-1, [[Enum.at(list,i), Enum.at(list,i-n-1), random_neighbour( list , [Enum.at(list,i), Enum.at(list,i-n-1)],i )    ] | acc], n, m)
  defp imp2D(list, i, acc, n, m) when i > 1 and i < n , 
    do: imp2D(list, i-1, [[Enum.at(list,i), Enum.at(list,i-2), Enum.at(list,i+n-1), random_neighbour( list,[Enum.at(list,i), Enum.at(list,i-2), Enum.at(list,i+n-1)],i )  ] | acc], n, m)
  defp imp2D(list, i, acc, n, m) when i > (m - n ) and i<m, 
    do: imp2D(list, i-1, [[Enum.at(list,i), Enum.at(list,i-2), Enum.at(list,i-n-1), random_neighbour( list,[Enum.at(list,i), Enum.at(list,i-2), Enum.at(list,i-n-1)],i )   ] | acc], n, m)
  defp imp2D(list, i, acc, n, m) when rem(i,n) == 0 , 
    do: imp2D(list, i-1, [[Enum.at(list,i-2), Enum.at(list,i+n-1), Enum.at(list,i-n-1), random_neighbour( list,[Enum.at(list,i-2), Enum.at(list,i+n-1), Enum.at(list,i-n-1)],i)]| acc], n, m)
  defp imp2D(list, i, acc, n, m) when rem(i,n) == 1 , 
    do: imp2D(list, i-1, [[Enum.at(list,i), Enum.at(list,i+n-1), Enum.at(list,i-n-1), random_neighbour( list, [Enum.at(list,i), Enum.at(list,i+n-1), Enum.at(list,i-n-1)],i)] | acc], n, m)
  defp imp2D(list, i, acc, n, m), 
    do: imp2D(list, i - 1, [[Enum.at(list,i),Enum.at(list,i-2),Enum.at(list,i+n-1),Enum.at(list,i-n-1), random_neighbour( list, [Enum.at(list,i),Enum.at(list,i-2),Enum.at(list,i+n-1),Enum.at(list,i-n-1)],i ) ] | acc], n, m)

  def random_neighbour(list,n_list,i) do
    temp = list -- [Enum.at(list,i-1)]
    temp2 = temp --  n_list
    hd(Enum.shuffle(temp2))
  end  

####################################################################################################################
## Sends neighbour list to each node #####

  def send_neighbour_list(node_pid_list,neighbours_tuple,n) do
      for i <- 0..n-1 do
        GenServer.cast(Enum.at(node_pid_list,i), {:send_neighbour_list,Enum.at(neighbours_tuple,i)})
      end
  end

#####################################################################################################################
## Sends first message to random node ####

  def send_initial_message(message,pid) do
    IO.puts("Sending original message to");
    IO.inspect(pid);
    new_message = [message, 0 , 0, false]
    GenServer.cast(pid,{:receiver,new_message}) ;
  end

#################################################################################################################


def send_initial_gossip(message,pid) do
  IO.puts("Sending original message to");
  IO.inspect(pid);
  GenServer.cast(pid,{:receiver,"Message"}) ;
end

end
