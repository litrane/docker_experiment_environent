./rly config init
./rly chains add --file earth.json earth
./rly chains add --file mars.json mars
./rly paths add earth mars earth-mars --file ./earth_mars.json 
./rly keys restore earth testkey "eight goddess calm short core obey menu quick dose engine sniff hello curve perfect note tortoise pool end waste curious panic sad symbol good"
./rly keys restore mars testkey "rubber peasant enable evoke brick present detect valid harvest pet aunt upon sad ski april tunnel picnic stadium doctor divert sure nothing endorse phrase"
./rly tx link earth-mars --src-port transfer --dst-port transfer --order unordered --version ics20-1 -d