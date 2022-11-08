package keeper

import (
	"github.com/informalsystems/hermes-hackatom-demo/earth/x/earth/types"
)

var _ types.QueryServer = Keeper{}
