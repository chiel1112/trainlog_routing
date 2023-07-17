api_version = 4

Set = require('lib/set')
Sequence = require('lib/sequence')
Handlers = require("lib/way_handlers")

function setup()
  local ferry_speed = 30  -- ferry speed in km/h
  return {
    properties = {
      weight_name                   = 'duration',
      max_speed_for_map_matching    = 30/3.6,  -- kmph -> m/s
      call_tagless_node_function    = false,
      use_turn_restrictions         = false,
    },

    default_mode            = mode.ferry,
    default_speed           = ferry_speed,
    oneway_handling         = 'ignore',  -- allow traversal in both directions

    -- Only allow ways tagged as ferry route
    access_tag_whitelist = Set {
      'ferry'
    },

    speeds = Sequence {
      route = {
        ferry = ferry_speed,
      }
    },
  }
end

function process_node(profile, node, result)
  -- empty, ferry routes are mainly defined by ways, not nodes
end

function process_way(profile, way, result)
  -- only consider ways tagged with 'route=ferry'
  local is_ferry = way:get_value_by_key('route')
  if is_ferry == 'ferry' then
    result.forward_mode = mode.ferry
    result.backward_mode = mode.ferry
    result.forward_speed = profile.default_speed
    result.backward_speed = profile.default_speed
  else
    result.forward_mode = mode.inaccessible
    result.backward_mode = mode.inaccessible
  end
end

return {
  setup = setup,
  process_way =  process_way,
  process_node = process_node,
}