wifi.sta.getap(GetAPList);

print("Starting the WebServer")

srv=net.createServer(net.TCP)
srv:listen(80,
    function(conn)
        conn:on("receive", function(client,request)
            local buf = "";
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
            if(method == nil)then
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
            end
            local _GET = {}
            if (vars ~= nil)then
                for k, v in string.gmatch(vars, "(%w+)=([%w+-]*)&*") do
                    _GET[k] = v
                end
                file.remove(gConfgiFile);
                file.open(gConfgiFile,"w+");
                file.writeline(_GET.ssid);
                file.writeline(_GET.pass);
                file.close();
                node.restart();
                buf = buf.."<HTML><HEAD><meta http-equiv=\"refresh\" content=\"0;/\"></HEAD></HTML>"
            end
            if(_GET.ssid == nil)then
            buf = buf..[[
            <HTML><HEAD><TITLE>ENTER NEW AP PARAMETERS</TITLE>
            <meta name=viewport content="width=device-width, initial-scale=1, user-scalable=no">
            <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
            <BODY>
            <center><H1>ENTER NEW AP PARAMETERS</H1>]]..
            gAPList .."<P>"..gPPM.." "..gTemp..
            [[</center><FORM ACTION=><TABLE><TR>
            <TD>SSID:</TD><TD><INPUT TYPE=TEXT NAME=ssid></TD></TR>
            <TD>PASS:</TD><TD><INPUT TYPE=PASSWORD NAME=pass></TD></TR>
            <TD>&nbsp;</TD><TD><INPUT TYPE=SUBMIT></TD></TR></TABLE></FORM>
            </BODY></HTML>
            ]];
            end
            client:send(buf);
            client:close();
            collectgarbage();
        end)
    end)
