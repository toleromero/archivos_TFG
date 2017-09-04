threadFunction=function()
   while simGetSimulationState()~=sim_simulation_advancing_abouttostop do
        
        -- Estas funciones obtienen el valor de las distancias en metros
        sensor2=simExtK3_getInfrared(k3Handle,2) -- sensor frontal izquierdo (vista superior)
        sensor3=simExtK3_getInfrared(k3Handle,3) -- sensor frontal derecho (vista superior)

        -- Si detecta algo con los sensores frontales y tiene los brazos subidos
        if (sensor2<=0.02 or sensor3<=0.02) and (pinzas==1) then 
            simExtK3_setVelocity(k3Handle,-velLeft,-velRight) -- retrocede
            simExtK3_setArmPosition(k3Handle,300) -- baja los brazos
            simWait(3)
            -- Indica con la variable booleana que las pinzas están bajadas
            pinzas=0
            simExtK3_setVelocity(k3Handle,velLeft,velRight) -- avanza
        end

        -- Estas funciones obtienen el valor de las distancias obtenidas por las pinzas
        pinza_izquierda=simExtK3_getGripperProxSensor(k3Handle,1)
        pinza_derecha=simExtK3_getGripperProxSensor(k3Handle,0)

        -- Si las pinzas detectan algún objeto y están bajadas
        if (pinza_derecha<0.03 or pinza_izquierda<0.03) and (pinzas==0) then
            -- Avanza un poquito porque los sensores están en los extremos de las pinzas y no 
            -- agarra bien el objeto
            simExtK3_setVelocity(k3Handle,velLeft,velRight)
            simWait(0.25)
            -- Stop -> hay que meterlo para que no haya un solapamiento de instrucciones
            simExtK3_setVelocity(k3Handle,0,0)
            simExtK3_setGripperGap(k3Handle,0) -- cierra los dedos para agarrar el objeto
            simWait(1)
            simExtK3_setArmPosition(k3Handle,900) -- sube los brazos para que nada le moleste el giro
            simWait(3)
            simExtK3_setVelocity(k3Handle,velLeft/2,-velRight/2) -- giro de 90º a la derecha
            simWait(2)
            -- Stop -> hay que meterlo para que no haya un solapamiento de instrucciones
            simExtK3_setVelocity(k3Handle,0,0)
            simExtK3_setArmPosition(k3Handle,300) -- baja los brazos para dejar el objeto
            simWait(5)
            simExtK3_setGripperGap(k3Handle,170) -- abre los dedos para soltar el objeto
            simWait(1)
            simExtK3_setArmPosition(k3Handle,900) -- sube los brazos para que nada le moleste en el giro
            simWait(3)
            -- Se avisa de que las pinzas vuelven a estar arriba
            pinzas=1
            simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2) -- giro de 90º a la izquierda
            simWait(2)
            -- Stop -> hay que meterlo para que no haya un solapamiento de instrucciones
            simExtK3_setVelocity(k3Handle,0,0)
        end

        simExtK3_setVelocity(k3Handle,velLeft,velRight)
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

velLeft=math.pi -- Velocidad para la rueda izquierda
velRight=math.pi -- Velocidad para la rueda derecha
pinzas=1 -- Brazos arriba

-- Ejecución del hilo de código:
res,err=xpcall(threadFunction,function(err) return debug.traceback(err) end)
if not res then
    simAddStatusbarMessage('Lua runtime error: '..err)
end

-- Limpieza
-- Destrucción del obketo K3
simExtK3_destroy(k3Handle)