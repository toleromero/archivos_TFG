threadFunction=function()
    while simGetSimulationState()~=sim_simulation_advancing_abouttostop do

        -- Estas funciones obtienen el valor de las distancias en metros para cada uno de los 9 sensores que tiene el robot
        sensor0=simExtK3_getInfrared(k3Handle,0) -- sensor lateral izquierdo (vista superior)
        sensor1=simExtK3_getInfrared(k3Handle,1) -- sensor diagonal izquierdo (vista superior)
        sensor2=simExtK3_getInfrared(k3Handle,2) -- sensor frontal izquierdo (vista superior)
        sensor3=simExtK3_getInfrared(k3Handle,3) -- sensor frontal derecho (vista superior)
        sensor4=simExtK3_getInfrared(k3Handle,4) -- sensor diagonal derecho (vista superior)
        sensor5=simExtK3_getInfrared(k3Handle,5) -- sensor lateral derecho (vista superior)
        sensor6=simExtK3_getInfrared(k3Handle,6) -- sensor trasero derecho (vista superior)
        sensor7=simExtK3_getInfrared(k3Handle,7) -- sensor trasero frontal (vista superior)
        sensor8=simExtK3_getInfrared(k3Handle,8) -- sensor trasero izquierdo (vista superior)

        -- La probabilidad tanto de avance como de giro será de un 50%
        probabilidad_movimientos=math.random(1,2)
        -- La velocidad también se aleatoriza
        avance=math.random(1,math.pi)

        -- El 2 se ha asignado para giros, mientras que el 1 es para avanzar en línea recta
        if (probabilidad_movimientos==2) then
        -- La probabilidad tanto de giro a izquierda como a derecha también será de un 50%           
            direccion_giro=math.random(1,2)

            -- El 1 se ha asignado para giros hacia izquierda, mientras que el 2 es para derecha
            if (direccion_giro==1) then -- giro a izquierda
                velLeft=-avance
                velRight=avance
            else -- giro a derecha
                velLeft=avance
                velRight=-avance
            end
        -- Si la primera variable aleatoria es 1, avanza en línea recta
        else
            velLeft=avance
            velRight=avance
        end

        -- Si alguno de los 2 sensores diagonales traseros detectan algo, reduce la velocidad 
        -- para que los robots de detrás no se pierdan
        if (sensor6<0.15 or sensor7<0.15) then
            simExtK3_setVelocity(k3Handle,velLeft/2,velRight/2)
        end

        -- Se define la velocidad de todos los giros a realizar
        giro=math.pi/2

        -- Si el sensor frontal izquierdo o diagonal izquierdo detectan algo muy cercano, se para
        -- para evitar colisionar
        if (sensor2<0.07 and sensor1<0.05) then
            simExtK3_setVelocity(k3Handle,giro*0,giro*0) -- stop

        -- Si el sensor diagonal izquierdo detecta algo y el frontal izquierdo no detecta nada,
        -- gira más brusco hacia la izquierda
        elseif (sensor2>0.1 and sensor1<0.1) then
            simExtK3_setVelocity(k3Handle,giro/2,giro*2) -- giro a izquierda
            simWait(2/6/2) 

        -- Si el sensor diagonal izquierdo no detecta nada y el frontal izquierdo detecta algo,
        -- gira ligeramente hacia la derecha          
        elseif (sensor1>0.1 and sensor2<0.1) then
            simExtK3_setVelocity(k3Handle,giro,-giro) -- giro a derecha
            simWait(2/6/2)

        -- Si el sensor lateral izquierdo detecta algo a una pequeña distancia, gira ligeramente
        -- hacia la derecha para evitar chocarse con el robot de al lado
        elseif (sensor0<0.03) then
            simExtK3_setVelocity(k3Handle,giro,-giro) -- giro a derecha
            simWait(2/6/2)

        -- Si 2'5 veces el sensor frontal izquierdo es menor que el sensor diagonal izquierdo, 
        -- giro ligeramente hacia la derecha
        elseif (sensor2*2.5<sensor1) then
            simExtK3_setVelocity(k3Handle,giro,-giro) -- giro a derecha
            simWait(2/6/2)


        -- Si el sensor frontal derecho o diagonal derecho detectan algo muy cercano, se para
        -- para evitar colisionar        
        elseif (sensor3<0.07) and (sensor4<0.05) then
            simExtK3_setVelocity(k3Handle,giro*0,giro*0) -- stop

        -- Si el sensor diagonal derecho detecta algo y el frontal derecho no detecta nada,
        -- gira más brusco hacia la derecha        
        elseif (sensor3>0.1) and (sensor4<0.1) then
            simExtK3_setVelocity(k3Handle,giro*2,giro/2) -- giro a derecha
            simWait(2/6/2)
        
        -- Si el sensor diagonal derecho no detecta nada y el frontal derecho detecta algo,
        -- gira ligeramente hacia la izquierda
        elseif (sensor4>0.1) and (sensor3<0.1) then
            simExtK3_setVelocity(k3Handle,-giro,giro) -- giro a izquierda
            simWait(2/6/2)

        -- Si el sensor lateral derecho detecta algo a una pequeña distancia, gira ligeramente
        -- hacia la izquierda para evitar chocarse con el robot de al lado
        elseif (sensor5<0.03) then
            simExtK3_setVelocity(k3Handle,-giro,giro) -- giro a izquierda
            simWait(2/6/2)

        -- Si 2'5 veces el sensor frontal derecho es menor que el sensor diagonal derecho, 
        -- giro ligeramente hacia la izquierda
        elseif (sensor3*2.5 < sensor4) then
            simExtK3_setVelocity(k3Handle,-giro,giro) -- giro a izquierda
            simWait(2/6/2)

        
        -- Si no se cumple ninguna de las condiciones, sigue recto
        else
            simExtK3_setVelocity(k3Handle,giro*1.15,giro*1.15)

        end
    end
end


-- Códigos de inicialización:

-- Comprobación de si existen los plugins necesarios:
-- ************************************************
moduleName=0
moduleVersion=0
index=0
kheperaModuleNotFound=true
-- Si el Khepera 3 se encuentra...
while moduleName do
    moduleName,moduleVersion=simGetModuleName(index)
    -- simGetModuleName se usa para verificar si un módulo específico está presente
    -- la función devuelve el moduleName: nombre del módulo o nulo
    -- la función devuelve el moduleVersion: versión del plugin o nulo
    if (moduleName=='K3') then
        kheperaModuleNotFound=false
    end
    index=index+1
end
-- Si es verdad que el Khepera 3 no se encuentra, se muestra un mensaje de error
if (kheperaModuleNotFound) then
    simDisplayDialog('Error','Khepera3 plugin was not found. (v_repExtK3.dll)&&nSimulation will not run properly',sim_dlgstyle_ok,true,nil,{0.8,0,0,0,0,0},{0.5,0,0,1,1,1})
end
-- ************************************************

-- Creaación del objeto K3:
local wheelMotorHandles={simGetObjectHandle('K3_leftWheelMotor'),simGetObjectHandle('K3_rightWheelMotor')}
local colorSensorHandles={simGetObjectHandle('K3_colorSensorLeft'),simGetObjectHandle('K3_colorSensorRight')}
local irSensorHandles={}
for i=1,9,1 do
    irSensorHandles[#irSensorHandles+1]=simGetObjectHandle('K3_infraredSensor'..i)
end
local usSensorHandles={}
for i=1,5,1 do
    usSensorHandles[#usSensorHandles+1]=simGetObjectHandle('K3_ultrasonicSensor'..i)
end
local armMotorHandles={-1,-1,-1,-1,-1,-1}
armMotorHandles[1]=simGetObjectHandle('K3_gripper_armJoint1')
armMotorHandles[2]=simGetObjectHandle('K3_gripper_armJoint2')
armMotorHandles[3]=simGetObjectHandle('K3_gripper_armAuxJoint1')
armMotorHandles[4]=simGetObjectHandle('K3_gripper_armAuxJoint2')
armMotorHandles[5]=simGetObjectHandle('K3_gripper_armAuxJoint3')
armMotorHandles[6]=simGetObjectHandle('K3_gripper_armAuxJoint4')
local fingerMotorHandles={-1,-1,-1}
fingerMotorHandles[1]=simGetObjectHandle('K3_gripper_fingers')
fingerMotorHandles[2]=simGetObjectHandle('K3_gripper_fingersAux')
fingerMotorHandles[3]=simGetObjectHandle('K3_gripper_fingersAux0')
local gripperDistSensHandles={simGetObjectHandle('K3_gripper_leftDistanceSensor'),simGetObjectHandle('K3_gripper_rightDistanceSensor')}
local gripperColSensHandles={simGetObjectHandle('K3_gripper_leftColorSensor'),simGetObjectHandle('K3_gripper_rightColorSensor')}
local uiHandle=simGetUIHandle('K3_stateVisualization')

k3Handle=simExtK3_create(wheelMotorHandles,colorSensorHandles,irSensorHandles,usSensorHandles,armMotorHandles,fingerMotorHandles,gripperDistSensHandles,gripperColSensHandles,uiHandle)

simExtK3_setGripperGap(k3Handle,170) -- Dedos abiertos
simExtK3_setArmPosition(k3Handle,900) -- Brazos arriba para que los sensores tengan visibilidad

-- Ejecución del hilo de código:
res,err=xpcall(threadFunction,function(err) return debug.traceback(err) end)
if not res then
    simAddStatusbarMessage('Lua runtime error: '..err)
end

-- Limpieza
-- Destrucción del obketo K3
simExtK3_destroy(k3Handle)