######################
## STATE OF PUSHSUM ##
######################
## 1. List of nghbr ##
## 2. si            ##
## 3. wi            ##
## 4. counter       ##
######################

defmodule PushSum do
  use GenServer

    def init(data_list) do
        {:ok, data_list}
    end

    def handle_cast({:send_neighbour_list,list},data_list) do
        {:noreply,[list | data_list]}
    end

    def handle_cast({:receiver,message},data_list) do

        if Enum.at(data_list,3) < 3 do
            old_ratio = Enum.at(data_list,1)/Enum.at(data_list,2)
            new_si = (Enum.at(data_list,1) + Enum.at(message,1))/2     
            new_wi = (Enum.at(data_list,2) + Enum.at(message,2))/2 
            new_ratio = new_si/new_wi 
            counter = Enum.at(data_list,3) 
            # check terminating condition
            if ( abs(old_ratio-new_ratio) < :math.pow(10,-10)) do
            # got updated
                counter = counter + 1 ;
            else
                if Enum.at(data_list,3) > 0  do 
                    counter = 0 ; # non consecutive case
                end
            end 

            temp_list = [Enum.at(data_list,0), new_si, new_wi , counter, false]

            new_list = send_to_random_neighbour(Enum.at(data_list,0),["message",new_si, new_wi])    

            {:noreply,temp_list}
        else 
            Process.exit(self(),:normal)
            {:noreply,data_list}
        end
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

    def send_message(pid,message) do
        GenServer.cast(pid,{:receiver,message})
    end

    def random_node(node_list) do
        a = length(node_list)
        Enum.at(node_list,:rand.uniform(a)-1)
    end
end