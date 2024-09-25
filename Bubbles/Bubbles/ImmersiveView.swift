//
//  ImmersiveView.swift
//  Bubbles
//
//  Created by Silvina Roldan on 25/09/2024.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel
    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var timer: Timer?

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "BubbleScene", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
        }
        .gesture(SpatialTapGesture().targetedToEntity(where: predicate).onEnded { value in
            let entity = value.entity
            guard var material = entity.components[ModelComponent.self]?.materials.first as? ShaderGraphMaterial else { return }
            let frameRate: TimeInterval = 1.0 / 60.0 // 60 frames per second
            let duration: TimeInterval = 0.25
            let targetValue: Float = 1
            let totalFrames = Int(duration / frameRate)

            //let animation = Animation.linear(duration: duration).repeatForever()

            var currentFrame = 0
            var popValue: Float = 0.0
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true, block: { timer in
                currentFrame += 1
                let progress = Float(currentFrame) / Float(totalFrames)
                popValue = progress * targetValue
                do {
                    try material.setParameter(name: "Pop", value: .float(popValue))
                    entity.components[ModelComponent.self]?.materials = [material]
                } catch {
                    print("Error setting parameter: \(error)")
                }
                
                if currentFrame >= totalFrames {
                    timer.invalidate()
                    entity.removeFromParent()
                }
            })
        })
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
