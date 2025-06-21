-- تعريف المتغير الذي يتحكم بحالة حلقة السرعة
local superSpeedLoop = false

-- هذه الدالة ستتحكم بتفعيل وإيقاف السوبر سبيد
local function toggleSuperSpeed(enable)
    superSpeedLoop = enable -- تحديث حالة الحلقة بناءً على ما جاء من الـ NUI

    if enable then
        -- بدء حلقة السوبر سبيد
        -- Citizen.CreateThread تبدأ "خيط" (Thread) جديد يعمل بشكل متوازٍ
        Citizen.CreateThread(function()
            -- هذه الحلقة ستستمر في العمل طالما أن superSpeedLoop = true
            while superSpeedLoop do
                local playerPed = PlayerPedId() -- الحصول على كائن اللاعب (Ped) الحالي
                
                -- تطبيق مضاعفات السرعة الأساسية للجري والسباحة
                -- PlayerId() هو معرف اللاعب (Player ID)
                SetRunSprintMultiplierForPlayer(PlayerId(), 3.0) 
                SetSwimMultiplierForPlayer(PlayerId(), 3.0)
                -- تحديد معدل حركة الشخصية العام (قد يؤثر على المشي/الهرولة)
                SetPedMoveRateOverride(playerPed, 2.5) 
                
                -- تسريع إضافي للحركة الأمامية (من الكود الذي قدمته)
                -- IsPedRunning و IsPedSprinting تتحققان إذا كان اللاعب يجري أو يهرول
                if IsPedRunning(playerPed) or IsPedSprinting(playerPed) then
                    local forwardVector = GetEntityForwardVector(playerPed) -- الحصول على الاتجاه الذي يواجهه اللاعب
                    local velocity = GetEntityVelocity(playerPed) -- الحصول على سرعة اللاعب الحالية
                    
                    -- تطبيق قوة إضافية في اتجاه الأمام لزيادة السرعة
                    SetEntityVelocity(playerPed, 
                        velocity.x + forwardVector.x * 0.5, -- زيادة السرعة في محور X
                        velocity.y + forwardVector.y * 0.5, -- زيادة السرعة في محور Y
                        velocity.z                           -- الحفاظ على السرعة في محور Z (الارتفاع)
                    )
                end
                
                Citizen.Wait(0) -- انتظار 0 مللي ثانية، يسمح لـ FiveM بتشغيل أكواد أخرى بسلاسة
            end
            
            -- عند خروج الحلقة (عندما superSpeedLoop يصبح false)، يتم تنفيذ هذا الجزء لـ"تنظيف"
            -- إعادة قيم السرعة إلى الوضع الطبيعي (1.0)
            local playerPed = PlayerPedId()
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
            SetSwimMultiplierForPlayer(PlayerId(), 1.0)
            SetPedMoveRateOverride(playerPed, 1.0)
        end)
    else
        -- إذا كانت `enable` هي `false`، فهذا يعني أننا نريد إيقاف السرعة.
        -- بتغيير `superSpeedLoop` إلى `false`، ستتوقف الحلقة تلقائياً.
        -- الكود الذي يلي الحلقة (إعادة تعيين السرعة إلى 1.0) سينفذ تلقائياً بمجرد توقف الحلقة.
    end
end

-- استقبال الحدث من NUI (ملف HTML)
-- 'toggleFastRun' هو اسم الحدث الذي نرسله من JavaScript
RegisterNuiCallback('toggleFastRun', function(data, cb)
    local state = data.state -- نستقبل البيانات المرسلة من JavaScript، وهي هنا حالة التوغل (true أو false)
    
    -- استدعاء دالة تبديل السرعة مع الحالة المستلمة
    toggleSuperSpeed(state)
    
    -- cb() هي دالة رد الاتصال (Callback) التي ترسل رداً إلى NUI.
    -- هذا اختياري، لكن من الجيد استخدامه لإعلام NUI بأن الحدث تم استلامه.
    cb('ok') 
end)
