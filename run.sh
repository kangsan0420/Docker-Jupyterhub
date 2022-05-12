docker run -d -v /DATA/SNU_EBUS/:/VOLUME/ -p 9021:80 --ulimit core=0 --name jupyter mnc_jupyter:v0.2
