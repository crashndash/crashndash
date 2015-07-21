module ("unloader", package.seeall)

cleanUp = function ( state )
  if not state then return end
  if state.layer and state.layer.props then
    for i, prop in next, state.layer.props, nil do
      state.layer:removeProp(prop)
      prop = nil
    end
    state.layer.props = nil
  end
  menu.onUnload(state.layer)
  if state.layerTable then
    for i, layers in ipairs ( state.layerTable ) do
      for j, layer in ipairs ( layers ) do
        layer = nil
      end
    end
  end
  state.layerTable = nil
end
