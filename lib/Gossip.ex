######################
## STATE OF GOSSIP  ##
######################
## 1. List of nghbr ##
## 2. counter       ##
## 3. frst counter  ##
######################

defmodule Gossip do
  use GenServer

    def init(data_list) do
        {:ok, data_list}
    end

    def handle_cast({:send_neighbour_list,list},data_list) do
        {:noreply,[list | data_list]}
    end

    def handle_cast({:receiver,message},data_list) do
        counter = Enum.at(data_list,1)
        counter = counter + 1 
        if counter < 10 do
            if Enum.at(data_list,2) == true do
                periodic_sender()
            end
        else
            Process.exit(self(),:normal);
        end
        temp_list = [ Enum.at(data_list,0),counter,false] 
        {:noreply,temp_list}
    end

    def periodic_sender() do
        GenServer.cast(self(),{:periodic_sender})
    end

    def handle_cast({:periodic_sender},data_list) do
        new_list = send_to_random_neighbour(Enum.at(data_list,0),["message"])
        if  List.first(new_list) != nil do
            Process.sleep(10)
            periodic_sender()
        else
            Process.exit(self(),:normal)
        end
        {:noreply,data_list}
    end

    def send_message(pid,message) do
        GenServer.cast(pid,{:receiver,message})
    end

    def random_node(node_list) do
        a = length(node_list)        
        Enum.at(node_list,(:rand.uniform(a)-1))
    end

    def send_to_random_neighbour(neighbour_list,message) do
        
        if List.first(neighbour_list) == nil do
            neighbour_list
        else
            next_node = random_node(neighbour_list)
            if (Process.alive?(next_node) == true) do
                send_message( next_node , message)
                neighbour_list
            else
                new_list = neighbour_list -- [next_node]
                send_to_random_neighbour(new_list,message)
            end
        end
    end

    def send_to_self(message) do
        IO.puts "Inside send to self"
        GenServer.cast(self(),{:receiver,message})
    end

end
