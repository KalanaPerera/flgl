import 'dart:typed_data';

import 'package:flgl/flutter3d/geometries/plane_geometry.dart';
import 'package:flgl/flutter3d/geometries/shaders/plane_fragment_shader.dart';
import 'package:flgl/flutter3d/geometries/shaders/plane_vertex_shader.dart';
import 'package:flgl/flutter3d/geometries/triangle_geometry.dart';
import 'package:flgl/flutter3d/math/m4.dart';
import 'package:flgl/flutter3d/math/vector3.dart';
import 'package:flgl/flutter3d/shaders/triangle_shaders.dart';
import 'package:flgl/openGL/contexts/open_gl_context_es.dart';

import '../flutter3d.dart';
import 'buffer_geometry.dart';

class Object3D {
  // some uniforms
  // dynamic program;
  ProgramInfo? programInfo;

  /// OpenGLES context.
  OpenGLContextES gl;

  /// The object geometry.
  BufferGeometry geometry;

  /// The object VAO.
  dynamic vao; // is int

  /// The object uniforms.
  Map<String, dynamic> uniforms = {};

  /// The object position
  Vector3 position = Vector3();

  /// The object rotation.
  Vector3 rotation = Vector3();

  /// The object scale.
  Vector3 scale = Vector3(1, 1, 1);

  /// The object matrix4 or u_world matrix.
  List<double> matrix = M4.identity();

  Object3D(this.gl, this.geometry) {
    if (geometry is PlaneGeometry) {
      setupPlane();
    } else if (geometry is TriangleGeometry) {
      setupTriangle(geometry);
    } else {
      print('Unkown geometry');
    }
  }

  /// Compose the object matrix.
  updateMatrix() {
    matrix = M4.translate(M4.identity(), position.x, position.y, position.z);
    matrix = M4.xRotate(matrix, rotation.x);
    matrix = M4.yRotate(matrix, rotation.y);
    matrix = M4.zRotate(matrix, rotation.z);
    matrix = M4.scale(matrix, scale.x, scale.y, scale.z);
    uniforms['u_world'] = matrix; // update the uniforms.
  }

  /// Set's the object position.
  setPosition(Vector3 v) {
    position = v;
    updateMatrix();
  }

  /// Set's the object rotation.
  setRotation(Vector3 v) {
    rotation = v;
    updateMatrix();
  }

  /// Set's the object scale.
  setScale(Vector3 v) {
    scale = v;
    updateMatrix();
  }

  setupTriangle(BufferGeometry geometry) {
    // 1. Create a program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(
      gl,
      triangleShaders['vertexShader']!,
      triangleShaders['fragmentShader']!,
    );

    // 2. Compute the buffer info
    geometry.computeBufferInfo(gl);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);
  }

  setupPlane() {
    // init program based on geometry and material
    programInfo = Flutter3D.createProgramInfo(gl, planeVertexShaderSource, planeFragmentShaderSource);

    // Setup VAO
    vao = Flutter3D.createVAOFromBufferInfo(gl, programInfo!, geometry.bufferInfo);

    // make a 8x8 checkerboard texture
    int checkerboardTexture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, checkerboardTexture);
    gl.texImage2D(
        gl.TEXTURE_2D,
        0, // mip level
        gl.LUMINANCE, // internal format
        8, // width
        8, // height
        0, // border
        gl.LUMINANCE, // format
        gl.UNSIGNED_BYTE, // type
        Uint8List.fromList([
          0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
          0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
          0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
          0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
          0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
          0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
          0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, //
          0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, 0xCC, 0xFF, //
        ]));
    gl.generateMipmap(gl.TEXTURE_2D);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

    uniforms['u_texture'] = checkerboardTexture;
  }
}

class OpenGLTexture {
  OpenGLTexture();
}
