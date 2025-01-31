use "collections"
use "random"
use "time"

actor ChordNetwork
  let nodes_list: Array[ChordActor] = Array[ChordActor]
  let env: Env
  let total_nodes: USize
  let total_requests: USize
  var accumulated_hops: USize = 0
  var finished_requests: USize = 0
  
  new create(total_nodes': USize, total_requests': USize, env': Env) =>
    total_nodes = total_nodes'
    total_requests = total_requests'
    env = env'

  be initiate() =>
    // Creating the peers
    for i in Range(0, total_nodes) do
      let node_instance = ChordActor(i, total_nodes, this, env)
      nodes_list.push(node_instance)
    end

    // Initializing the finger tables for peers
    for i in Range(0, total_nodes) do
      try
        nodes_list(i)?.setup_finger_table(i, total_nodes)
      end
    end

    // Triggering the lookup requests
    for node in nodes_list.values() do
      node.initiate_requests(total_requests)
    end

  be record_hops(hops: USize) =>
    accumulated_hops = accumulated_hops + hops
    finished_requests = finished_requests + 1
    
    // Displaying here average hops once all requests are completed
    if finished_requests == (total_nodes * total_requests) then
      let average_hops = accumulated_hops.f64() / finished_requests.f64()
      env.out.print("")
      env.out.print("Average number of hops required to complete the message routing: " + average_hops.string())
    end

  be get_actor(index: USize, callback: {(ChordActor tag)} val) =>
    try
      callback(nodes_list(index % total_nodes)?)
    end

actor ChordActor
  let identifier: USize
  let bit_count: USize
  let network: ChordNetwork
  let env: Env
  let finger_entries: Array[USize] = Array[USize]
  let rng: Random = Rand(Time.nanos())
  let max_nodes: USize
  
  new create(identifier': USize, node_count: USize, network_ref: ChordNetwork, env_ref: Env) =>
    identifier = identifier'
    bit_count = node_count.isize().bitwidth()
    network = network_ref
    env = env_ref
    max_nodes = node_count

  be setup_finger_table(node_id: USize, node_count: USize) =>
    // Setting up the finger table
    for i in Range(0, bit_count) do
      let entry_id = (node_id + (1 << i)) % node_count
      finger_entries.push(entry_id)
    end

  be initiate_requests(total_requests: USize) =>
    for _ in Range(0, total_requests) do
      let target_key = rng.next().usize() % max_nodes
      perform_lookup(target_key, 0, this)
    end

  be perform_lookup(key: USize, hops: USize, initiator: ChordActor tag) =>
    if is_node_responsible_for(key) then
      initiator.lookup_finished(hops)
    else
      let next_actor = find_closest_preceding(key)
      let initiating_actor = initiator
      let lookup_key = key
      let current_hops = hops
      network.get_actor(next_actor, {(next: ChordActor tag) => 
        next.perform_lookup(lookup_key, current_hops + 1, initiating_actor)
      })
    end

  be lookup_finished(hops: USize) =>
    network.record_hops(hops)

  fun ref find_closest_preceding(target: USize): USize =>
    var idx: USize = finger_entries.size()
    while idx > 0 do
      idx = idx - 1
      try
        let entry = finger_entries(idx)?
        if is_within_range(entry, identifier, target) then
          return entry
        end
      end
    end

    try
      finger_entries(0)?
    else
      identifier
    end

  fun ref is_within_range(entry_id: USize, start: USize, ending: USize): Bool =>
    if start < ending then
      (entry_id > start) and (entry_id < ending)
    else
      (entry_id > start) or (entry_id < ending)
    end

  fun ref is_node_responsible_for(key: USize): Bool =>
    try
      let successor_id = finger_entries(0)?
      if identifier < successor_id then
        (key > identifier) and (key <= successor_id)
      else
        (key > identifier) or (key <= successor_id)
      end
    else
      true
    end

actor Main
  new create(env: Env) =>
    let parameters = env.args
    if parameters.size() != 3 then
      env.out.print("Usage: project3 numNodes numRequests")
      return
    end

    try 
      let total_nodes = parameters(1)?.usize()?
      let total_requests = parameters(2)?.usize()?
      
      let chord_network = ChordNetwork(total_nodes, total_requests, env)
      chord_network.initiate()
    else
      env.out.print("Invalid number of nodes or requests")
    end
