package keeper

import (
	"github.com/informalsystems/hermes-hackatom-demo/mars/x/mars/types"
)

var _ types.QueryServer = Keeper{}
