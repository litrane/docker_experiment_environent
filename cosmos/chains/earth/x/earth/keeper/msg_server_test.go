package keeper_test

import (
	"context"
	"testing"

	sdk "github.com/cosmos/cosmos-sdk/types"
	keepertest "github.com/informalsystems/hermes-hackatom-demo/earth/testutil/keeper"
	"github.com/informalsystems/hermes-hackatom-demo/earth/x/earth/keeper"
	"github.com/informalsystems/hermes-hackatom-demo/earth/x/earth/types"
)

func setupMsgServer(t testing.TB) (types.MsgServer, context.Context) {
	k, ctx := keepertest.EarthKeeper(t)
	return keeper.NewMsgServerImpl(*k), sdk.WrapSDKContext(ctx)
}
