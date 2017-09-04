threadFunction=function()
    while simGetSimulationState()~=sim_simulation_advancing_abouttostop do

        -- Todo lo que sea inferior o igual a 0'5 será considerado como negro (0)
		-- para ambos sensores
        s_act_izq=simExtK3_getLineSensor(k3Handle,0)
        if (s_act_izq<=0.5) then
            s_act_izq=0
        else
            s_act_izq=1
        end

        s_act_der=simExtK3_getLineSensor(k3Handle,1)
        if (s_act_der<=0.5) then
            s_act_der=0
        else
            s_act_der=1
        end

        -- Si actualmente está en suelo negro y las pinzas están arriba, sigue recto
        -- Si los brazos están abajo significa que está en fase de coger objeto, por lo tanto,
        -- se le permite abandonar la línea
        if(s_act_izq==0 and s_act_der==0) and (pinzas==1) then
            simExtK3_setVelocity(k3Handle,velLeft,velRight)
            -- Recarga las posiciones anteriores, que son las actuales para tener un 
            -- historial de dónde ha estado la última vez y así poder realizar los
            -- giros pertinentes
            s_ant_izq=s_act_izq
            s_ant_der=s_act_der
        end

        -- Si se sale por la izquierda, anteriormente estuvo sobre la línea y los brazos
        -- están arriba, gira a la derecha 15º
        -- Si los brazoss están abajo significa que está en fase de coger objeto, por lo tanto,
        -- se le permite abandonar la línea
        if(s_act_izq==1 and s_act_der==0) and (s_ant_izq==0 and s_ant_der==0) and (pinzas==1) then
            simExtK3_setVelocity(k3Handle,velLeft/2,-velRight/2)
            simWait(2/6)
            
            -- Solo hay que recargar el sensor derecho, ya que el izquierdo ha estado
            -- fuera de la línea
            s_ant_der=s_act_der

            -- Variable booleana para comprobar la dirección de los giros: 0 indica
            -- giro a derecha, 1 indica giro a izquierda
            giro=0
        end
   
        -- Si se sale por la derecha, anteriormente estuvo sobre la línea y los brazos
        -- están arriba, gira a la izquierda 15º
        -- Si los brazoss están abajo significa que está en fase de coger objeto, por lo tanto,
        -- se le permite abandonar la línea
        if(s_act_izq==0 and s_act_der==1) and (s_ant_izq==0 and s_ant_der==0) and (pinzas==1) then
            simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2)
            simWait(2/6)

            -- Solo hay que recargar el sensor izquierdo, ya que el derecho ha estado
            -- fuera de la línea     
            s_ant_izq=s_act_izq
            
            giro=1
        end

        
        -- Si se sale por los dos lados a la vez, anteriormente estuvo sobre la 
        -- línea y los brazos están arriba, deberá hacer unos giros más bruscos
        -- Si los brazos están abajo significa que está en fase de coger objeto, por lo tanto,
        -- se le permite abandonar la línea
        if(s_act_izq==1 and s_act_der==1) and (s_ant_izq==0 and s_ant_der==0) and (pinzas==1) then
            -- Si el último giro fue a la derecha, gira 45º a la izquierda
            if (giro==0) then
                simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2)
                simWait(2/2)
                
                -- Al girar a la izquierda, es como si se hubiese salido por la derecha,
                -- entonces para que siga el giro a izquierda, se le establecen estos 
                -- parámetros para que entre en la condición de giro a izquierda y siga
                -- girando en esa misma dirección
                s_act_izq=0
                s_act_der=1
                
                -- Así se obliga a que vuelva a entrar aqui para seguir girando a la izquierda
                -- ya que los giros de 15º en ocasiones son insuficientes para salir del bloqueo
                giro=0
            
            -- Si el último giro fue a la izquierda, gira 45º a la derecha
            else
                simExtK3_setVelocity(k3Handle,velLeft/2,-velRight/2)
                simWait(2/2)
                
                s_act_izq=1
                s_act_der=0

                giro=1
            end
        end


        sensor1=simExtK3_getInfrared(k3Handle,1) -- sensor diagonal derecho (vista frontal)
        sensor2=simExtK3_getInfrared(k3Handle,2) -- sensor frontal derecho (vista frontal)
        sensor3=simExtK3_getInfrared(k3Handle,3) -- sensor frontal izquierdo (vista frontal)
        sensor4=simExtK3_getInfrared(k3Handle,4) -- sensor diagonal izquierdo (vista frontal)


    
        -- Si detecta algo con los sensores frontales y tiene los brazos subidos
        if (sensor2<=0.02 or sensor3<=0.02) and (pinzas==1) then 
            simExtK3_setVelocity(k3Handle,-velLeft,-velRight) -- retrocede
            simExtK3_setArmPosition(k3Handle,300) -- baja los brazos
            simWait(3)
            -- Indica con la variable booleana que las pinzas están bajadas
            pinzas=0
            simExtK3_setVelocity(k3Handle,velLeft,velRight) -- avanza
            -- Indica con la variable booleana que se va a realizar el movimiento de coger
            coger=1
        end

        -- Si detecta algo con el sensor lateral izquierdo y tiene los brazos subidos
        if (sensor1<=0.02) and (pinzas==1) then
            -- Giro a la izquierda de 45º aproximadamente
            simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2)
            simWait(2/2)
            simExtK3_setVelocity(k3Handle,-velLeft,-velRight) -- retrocede
            simExtK3_setArmPosition(k3Handle,350) -- baja los brazos
            simWait(3)
            -- Indica con la variable booleana que las pinzas están bajadas
            pinzas=0
            simExtK3_setVelocity(k3Handle,velLeft,velRight) -- avanza
            -- Indica con la variable booleana que se va a realizar el movimiento de coger
            coger=1
        end

        -- Si detecta algo con el sensor lateral derecho y tiene los brazos subidos
        if (sensor4<=0.02) and (pinzas==1) then 
            -- Giro a la derecha de 45º aproximadamente
            simExtK3_setVelocity(k3Handle,velLeft/2,-velRight/2)
            simWait(2/2)
            simExtK3_setVelocity(k3Handle,-velLeft,-velRight) -- retrocede
            simExtK3_setArmPosition(k3Handle,300) -- baja los brazos
            simWait(3)
            -- Indica con la variable booleana que las pinzas están bajadas
            pinzas=0
            simExtK3_setVelocity(k3Handle,velLeft,velRight) -- avanza
            -- Indica con la variable booleana que se va a realizar el movimiento de coger          
            coger=1
        end

        -- Estas funciones obtienen el valor de las distancias obtenidas por las pinzas
        pinza_izquierda=simExtK3_getGripperProxSensor(k3Handle,1)
        pinza_derecha=simExtK3_getGripperProxSensor(k3Handle,0)

        -- Si las pinzas detectan algún objeto y están bajadas, mientras se realiza el movimiento de coger objeto
        if(pinza_derecha<0.03 or pinza_izquierda<0.03) and (pinzas==0) and (coger==1) then
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
            -- Se indica que el movimiento de coger objeto ya ha finalizado
            coger=0
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
s_ant_izq=1 -- Fuera de la línea
s_ant_der=1 -- Fuera de la línea
giro=0 -- Derecha
pinzas=1 -- Brazos arriba
coger=0 -- Control de cogida de objetos

-- Ejecución del hilo de código:
res,err=xpcall(threadFunction,function(err) return debug.traceback(err) end)
if not res then
    simAddStatusbarMessage('Lua runtime error: '..err)
end

-- Limpieza
-- Destrucción del obketo K3
simExtK3_destroy(k3Handle)