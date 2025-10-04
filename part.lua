     local targetRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local targetHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
                        if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            local spawnTime = playerSpawnTimes[otherPlayer] or 0
                            local timeSinceSpawn = tick() - spawnTime
                            if distance <= killAuraRange and timeSinceSpawn > spawnProtectionTime then
                                table.insert(validTargets, otherPlayer.Character)
                            end
                        end
                    end
                end

                if #validTargets > 0 then
                    if attackMultipleTargets then
                        local selectedTarget = nil
                        local minDistance = math.huge
                        for _, target in ipairs(validTargets) do
                            if not table.find(lastAttackedTargets, target) then
                                local distance = (rootPart.Position - target:FindFirstChild("HumanoidRootPart").Position).Magnitude
                                if distance < minDistance then
                                    selectedTarget = target
                                    minDistance = distance
                                end
                            end
                        end
                        if not selectedTarget then
                            for _, target in ipairs(validTargets) do
                                local distance = (rootPart.Position - target:FindFirstChild("HumanoidRootPart").Position).Magnitude
                                if distance < minDistance then
                                    selectedTarget = target
                                    minDistance = distance
                                end
                            end
                            lastAttackedTargets = {}
                        end
                        currentTarget = selectedTarget
                        table.insert(lastAttackedTargets, currentTarget)
                    else
                        local closestTarget = nil
                        local minDistance = killAuraRange
                        for _, target in ipairs(validTargets) do
                            local distance = (rootPart.Position - target:FindFirstChild("HumanoidRootPart").Position).Magnitude
                            if distance < minDistance then
                                closestTarget = target
                                minDistance = distance
                            end
                        end
                        currentTarget = closestTarget
                    end
                else
                    currentTarget = nil
                    lastAttackedTargets = {}
                    lastSelectedTarget = nil
                end

                highlight.Parent = currentTarget

                if currentTarget then
                    local targetRoot = currentTarget:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = currentTarget:FindFirstChild("Humanoid")
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                        local currentTime = tick()
                        local shouldTeleport = false
                        if attackMultipleTargets and currentTarget ~= lastSelectedTarget then
                            if currentTime - lastMultiTargetTeleportTime >= multiTargetTeleportCooldown then
                                shouldTeleport = true
                                lastMultiTargetTeleportTime = currentTime
                            end
                        elseif currentTime - lastTeleportTime >= teleportCooldown then
                            shouldTeleport = true
                            lastTeleportTime = currentTime
                        end

                        if shouldTeleport then
                            local waitTime = math.random(10, 30) / 100
                            task.wait(waitTime)
                            local targetCFrame = targetRoot.CFrame
                            local teleportPosition
                            if killAuraMode == "Behind" then
                                teleportPosition = targetCFrame.Position - targetCFrame.LookVector * 3
                            else
                                teleportPosition = Vector3.new(targetCFrame.Position.X, targetCFrame.Position.Y - 0.1, targetCFrame.Position.Z)
                            end
                            local lookAtPosition = Vector3.new(targetRoot.Position.X, rootPart.Position.Y, targetRoot.Position.Z)
                            local baseCFrame = CFrame.new(teleportPosition, lookA