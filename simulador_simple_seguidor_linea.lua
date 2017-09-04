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

        -- Si actualmente está en suelo negro, sigue recto
        if(s_act_izq==0 and s_act_der==0) then
            simExtK3_setVelocity(k3Handle,velLeft,velRight)
            -- Recarga las posiciones anteriores, que son las actuales para tener un 
            -- historial de dónde ha estado la última vez y así poder realizar los
            -- giros pertinentes
            s_ant_izq=s_act_izq
            s_ant_der=s_act_der
        end

        -- Si se sale por la izquierda y anteriormente estuvo sobre la línea, gira
        -- a la derecha 15º
        if(s_act_izq==1 and s_act_der==0) and (s_ant_izq==0 and s_ant_der==0) then
            simExtK3_setVelocity(k3Handle,velLeft/2,-velRight/2)
            simWait(2/6)
            
            -- Solo hay que recargar el sensor derecho, ya que el izquierdo ha estado
            -- fuera de la línea
            s_ant_der=s_act_der

            -- Variable booleana para comprobar la dirección de los giros: 0 indica
            -- giro a derecha, 1 indica giro a izquierda
            giro=0
        end
   
        -- Si se sale por la derecha y anteriormente estuvo sobre la línea, gira
        -- a la izquierda 15º
        if(s_act_izq==0 and s_act_der==1) and (s_ant_izq==0 and s_ant_der==0) then
            simExtK3_setVelocity(k3Handle,-velLeft/2,velRight/2)
            simWait(2/6)

            -- Solo hay que recargar el sensor izquierdo, ya que el derecho ha estado
            -- fuera de la línea     
            s_ant_izq=s_act_izq
            
            giro=1
        end

        
        -- Si se sale por los dos lados a la vez y anteriormente estuvo sobre la 
        -- línea, deberá hacer unos giros más bruscos
        if(s_act_izq==1 and s_act_der==1) and (s_ant_izq==0 and s_ant_der==0) then
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

-- Ejecución del hilo de código:
res,err=xpcall(threadFunction,function(err) return debug.traceback(err) end)
if not res then
    simAddStatusbarMessage('Lua runtime error: '..err)
end

-- Limpieza
-- Destrucción del obketo K3
simExtK3_destroy(k3Handle)