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
        
        -- Estas son las distancias mínimas permitidas. Son diferentes para cada agrupación de
        -- sensores porque hay que tener en cuenta el Kh3-Gripper
		dist_min_frontal=0.06
        dist_min_diagonal=0.04
        dist_min_lateral=0.02
		
		-- Si los valores de los sensores frontales son mayores que la distancia mínima 
        -- frontal establecida, sigue su camino recto porque no detecta obstáculo
        if (sensor2>dist_min_frontal and sensor3>dist_min_frontal) then
            simExtK3_setVelocity(k3Handle,velLeft,velRight)

        -- Si los sensores frontales han detectado obstáculo...
        else
			-- Si los valores de los derechos (diagonal y lateral) son mayores que los 
            -- valores de los sensores izquierdos, el robot detecta obstáculo por la derecha		
            if (sensor1>sensor4 and sensor0>sensor5) then
                -- Gira hacia la izquierda de 15º
                simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2)
                simWait(2/6)
            
            -- Si, por el contrario, son mayores los valores de los sensores izquierdos, 
            -- el robot detecta el obstáculo por la izquierda	
            else
                -- Gira hacia la derecha de 15º
                simExtK3_setVelocity(k3Handle,velLeft/2,-velRight/2)
                simWait(2/6)
            end

        end

		-- Si el valor del sensor diagonal derecho es menor que la distancia mínima 
        -- diagonal establecida, hay que girar
        if (sensor1<dist_min_diagonal) then
            -- Se realiza un giro hacia la derecha de 15º porque el robot detecta un obstáculo 
            -- por el lateral izquierdo
            simExtK3_setVelocity(k3Handle,velLeft/2,-velRight/2)
            simWait(2/6)
        end
		
        -- Si el valor del sensor diagonal izquierdo es menor que la distancia mínima 
        -- diagonal establecida, hay que girar
        if (sensor4<dist_min_diagonal) then
            -- Se realiza un giro hacia la izquierda de 15º porque el robot detecta un 
            -- obstáculo por el lateral derecho
            simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2)
            simWait(2/6)
        end

		-- Si el valor del sensor lateral derecho es menor que la distancia mínima lateral 
        -- establecida, hay que girar
        if (sensor0<dist_min_lateral) then
            -- Se realiza un giro hacia la derecha de 15º porque el robot detecta un 
            -- obstáculo por el lateral izquierdo
            simExtK3_setVelocity(k3Handle,velLeft/2,-velRight/2)
            simWait(2/6)
        end

		-- Si el valor del sensor lateral izquierdo es menor que la distancia mínima lateral 
        -- establecida, hay que girar
        if (sensor5<dist_min_lateral) then
            -- Se realiza un giro hacia la izquierda de 15º porque el robot detecta un 
            -- obstáculo por el lateral derecho
            simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2)
            simWait(2/6)
        end

        -- Si el valor de los seis sensores frontales es inferior a la distancia minima frontal
        -- y el valor de los traseros es superior a esa distancia, quiere decir que se ha quedado
        -- encerrado y tiene quedar la media vuelta
        if (sensor2<dist_min_frontal and sensor3<dist_min_frontal and sensor0<dist_min_frontal and sensor5<dist_min_frontal and sensor6>dist_min_trasera and sensor7>dist_min_trasera and sensor8>dist_min_trasera) then
            -- Giro a la izquierda, por ejemplo, de 15º
            simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2)
            simWait(2/6)
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

velLeft=math.pi -- Velocidad para la rueda izquierda
velRight=math.pi -- Velocidad para la rueda derecha

-- Ejecución del hilo de código:
res,err=xpcall(threadFunction,function(err) return debug.traceback(err) end)
if not res then
    simAddStatusbarMessage('Lua runtime error: '..err)
end

-- Limpieza
-- Destrucción del obketo K3
simExtK3_destroy(k3Handle)