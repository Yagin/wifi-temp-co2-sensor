-- Файл для получения значения CO2, записываются в переменную gPPM

local vIndex  = 0
local vTL     = 0
local vTH     = 0
local vH      = 0
local vL      = 0

local function gpioCB( iLevel )

   local tt = tmr.now()/1000;
   
   if iLevel == gpio.HIGH then
      vH = tt
      vTL = vH - vL
   else
      vL = tt;
      vTH = vL - vH;
      gPPM = 5000 * (vTH - 2) / (vTH + vTL - 4)
   end     

   --  __1--2_______3--4__      
   if vIndex > 3 then 
      gpio.trig(gCo2pin) -- Снимаем прерывание
      local vTemp = split(tostring(gPPM),".")
      gPPM = vTemp[1]
      return
   end
   
   vIndex = vIndex + 1

   if iLevel == gpio.HIGH then
      gpio.trig(gCo2pin, "down")
   else
      gpio.trig(gCo2pin, "up")
   end

end -- local function pwmCB( iLevel )

gpio.mode(gCo2pin, gpio.INT) -- рижем прерываний 
gpio.trig(gCo2pin, "up", gpioCB) -- устанавливаем функцию на прерывание 
collectgarbage();
