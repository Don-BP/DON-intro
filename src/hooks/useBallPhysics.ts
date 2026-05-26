'use client'
import { useRef, useEffect, useCallback } from 'react'
import * as THREE from 'three'
import * as CANNON from 'cannon-es'

const MARBLE_PATHS = [
  '/assets/balls/marble1.png',
  '/assets/balls/marble2.png',
  '/assets/balls/marble3.png',
  '/assets/balls/marble4.png',
  '/assets/balls/marble5.png',
]

interface Options {
  ballHex: number
  ballSpec: number
}

export function useBallPhysics(
  containerRef: React.RefObject<HTMLDivElement>,
  options: Options
) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const sceneRef = useRef<{
    renderer: THREE.WebGLRenderer
    scene: THREE.Scene
    camera: THREE.PerspectiveCamera
    world: CANNON.World
    bodies: Array<{ body: CANNON.Body; mesh: THREE.Mesh }>
    animId: number
    WORLD_W: number
    FLOOR_Y: number
    ballMaterial: CANNON.Material
    textureLoader: THREE.TextureLoader
    textures: THREE.Texture[]
  } | null>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    const container = containerRef.current
    if (!canvas || !container) return

    const W = container.clientWidth
    const H = container.clientHeight
    if (W === 0 || H === 0) return

    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true })
    renderer.setSize(W, H)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    renderer.shadowMap.enabled = true
    renderer.shadowMap.type = THREE.PCFSoftShadowMap
    renderer.setClearColor(0x000000, 0)

    const scene = new THREE.Scene()
    const aspect = W / H
    const camera = new THREE.PerspectiveCamera(55, aspect, 0.1, 50)
    camera.position.set(0, 1.0, 7)
    camera.lookAt(0, -1.5, 0)

    scene.add(new THREE.AmbientLight(0xffffff, 0.55))
    const sun = new THREE.DirectionalLight(0xffffff, 0.9)
    sun.position.set(3, 8, 5)
    sun.castShadow = true
    sun.shadow.mapSize.set(512, 512)
    sun.shadow.camera.left = -5
    sun.shadow.camera.right = 5
    sun.shadow.camera.top = 5
    sun.shadow.camera.bottom = -5
    sun.shadow.bias = -0.001
    scene.add(sun)
    const fillLight = new THREE.DirectionalLight(0x8888ff, 0.3)
    fillLight.position.set(-4, 4, -4)
    scene.add(fillLight)

    const world = new CANNON.World({ gravity: new CANNON.Vec3(0, -28, 0) })
    world.broadphase = new CANNON.NaiveBroadphase()
    world.allowSleep = true

    const groundMat = new CANNON.Material('ground')
    const ballMat = new CANNON.Material('ball')
    world.addContactMaterial(new CANNON.ContactMaterial(groundMat, ballMat, { friction: 0.55, restitution: 0.22 }))
    world.addContactMaterial(new CANNON.ContactMaterial(ballMat, ballMat, { friction: 0.4, restitution: 0.18 }))

    const WORLD_W = 6
    const WORLD_H = WORLD_W / aspect
    const FLOOR_Y = -(WORLD_H / 2) - 0.2
    const WALL_T = 0.15

    function addStaticWall(x: number, y: number, z: number, hw: number, hh: number, hd: number) {
      const body = new CANNON.Body({ mass: 0, material: groundMat })
      body.addShape(new CANNON.Box(new CANNON.Vec3(hw, hh, hd)))
      body.position.set(x, y, z)
      world.addBody(body)
    }

    const halfW = WORLD_W / 2 + WALL_T
    addStaticWall(0, FLOOR_Y - WALL_T, 0, halfW, WALL_T, 2.5)
    addStaticWall(-halfW - WALL_T, 0, 0, WALL_T, WORLD_H, 2.5)
    addStaticWall(halfW + WALL_T, 0, 0, WALL_T, WORLD_H, 2.5)
    addStaticWall(0, 0, -2.5 - WALL_T, halfW + WALL_T * 2, WORLD_H, WALL_T)

    const textureLoader = new THREE.TextureLoader()
    const textures = MARBLE_PATHS.map(p => textureLoader.load(p))

    const bodies: Array<{ body: CANNON.Body; mesh: THREE.Mesh }> = []
    let animId = 0
    let lastTime = performance.now()

    function animate() {
      animId = requestAnimationFrame(animate)
      const now = performance.now()
      const dt = Math.min((now - lastTime) / 1000, 0.04)
      lastTime = now
      world.step(1 / 60, dt, 3)
      for (const { body, mesh } of bodies) {
        mesh.position.copy(body.position as unknown as THREE.Vector3)
        mesh.quaternion.copy(body.quaternion as unknown as THREE.Quaternion)
      }
      renderer.render(scene, camera)
    }
    animate()

    sceneRef.current = { renderer, scene, camera, world, bodies, animId, WORLD_W, FLOOR_Y, ballMaterial: ballMat, textureLoader, textures }

    const ro = new ResizeObserver(() => {
      const nW = container.clientWidth
      const nH = container.clientHeight
      renderer.setSize(nW, nH)
      camera.aspect = nW / nH
      camera.updateProjectionMatrix()
    })
    ro.observe(container)

    return () => {
      cancelAnimationFrame(animId)
      ro.disconnect()
      renderer.dispose()
      sceneRef.current = null
    }
  }, [containerRef])

  const dropBalls = useCallback((count: number) => {
    const s = sceneRef.current
    if (!s) return

    const BR = 0.28
    const { world, scene, bodies, WORLD_W, FLOOR_Y, ballMaterial, textures } = s

    while (bodies.length + count > 50) {
      const oldest = bodies.shift()
      if (oldest) {
        world.removeBody(oldest.body)
        scene.remove(oldest.mesh)
        oldest.mesh.geometry.dispose()
        ;(oldest.mesh.material as THREE.Material).dispose()
      }
    }

    for (let i = 0; i < count; i++) {
      setTimeout(() => {
        if (!sceneRef.current) return
        const halfW = WORLD_W / 2 - BR * 1.5
        const rx = (Math.random() * 2 - 1) * halfW
        const ry = FLOOR_Y + WORLD_W + BR + Math.random() * 0.5
        const rz = (Math.random() * 2 - 1) * 1.2

        const body = new CANNON.Body({
          mass: 1,
          material: ballMaterial,
          linearDamping: 0.02,
          angularDamping: 0.12,
          allowSleep: true,
          sleepSpeedLimit: 0.25,
        })
        body.addShape(new CANNON.Sphere(BR))
        body.position.set(rx, ry, rz)
        body.velocity.set((Math.random() - 0.5) * 0.5, 0, (Math.random() - 0.5) * 0.3)
        world.addBody(body)

        const tex = textures[Math.floor(Math.random() * textures.length)]
        const geo = new THREE.SphereGeometry(BR, 24, 24)
        const mat = new THREE.MeshPhongMaterial({
          map: tex,
          color: options.ballHex,
          specular: options.ballSpec,
          shininess: 160,
        })
        const mesh = new THREE.Mesh(geo, mat)
        mesh.castShadow = true
        scene.add(mesh)
        bodies.push({ body, mesh })
      }, i * 120)
    }
  }, [options.ballHex, options.ballSpec])

  return { canvasRef, dropBalls }
}
