// CSVファイルを読み込んで物体の姿勢を表示する
//
// 右手直交座標系における回転角
// X軸を画面の左向き，Y軸を右，Z軸を上向きにとる．

// 連番画像からMP4動画を作るFFmpegコマンド（outFramesディレクトリで実行する）
// ffmpeg -r 32 -i image_%d.png -vcodec libx264 -r 32 ./../../animation.mp4
//
// GIFならこっち↓
// ffmpeg -i image_%d.png -vf palettegen palette.png
// ffmpeg -f image2 -r 32 -i image_%d.png -i palette.png -filter_complex paletteuse ./../../animation.gif

float[] Time, Yaw, Pitch, Roll;
int global_data_index = 0;
int global_data_lines;

void setup() {
    size(400, 400, P3D);
    frameRate(32);
    textSize(16);

    Table table = loadTable("../result.csv");
    global_data_lines = table.getRowCount();
    Time  = new float[global_data_lines];
    Yaw   = new float[global_data_lines];
    Pitch = new float[global_data_lines];
    Roll  = new float[global_data_lines];
    for (int i = 0; i < global_data_lines; i++) {
        Time[i]  = table.getFloat(i, 0);
        Yaw[i]   = table.getFloat(i, 1);
        Pitch[i] = table.getFloat(i, 2);
        Roll[i]  = table.getFloat(i, 3);
    }
}

void draw() {
    background(128);  // 背景色

    fill(0);  // 文字の塗りつぶし色
    text("Time : " + Time[global_data_index] + "[s]", 5, 20);
    text("Yaw : "  + int( degrees(Yaw[global_data_index]) )   + "[deg]", 5, 40);
    text("Pitch: " + int( degrees(Pitch[global_data_index]) ) + "[deg]", 5, 60);
    text("Roll : " + int( degrees(Roll[global_data_index]) )  + "[deg]", 5, 80);
    text("X",  60, 280);
    text("Y", 330, 280);
    text("Z", 195, 40);

    pushMatrix();
    // 原点をウィンドウの中心に移動
    translate(width/2, height/2);

    // カメラ位置（視点）を調整
    camera(250, -200, 250, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);  // Y軸を天頂方向

    // 慣性座標系の矢印
    arrow(0, 0, 0, 0, 0, 150, 150, 0, 0);  // X（赤）
    arrow(0, 0, 0, 150, 0, 0, 0, 150, 0);  // Y（緑）
    arrow(0, 0, 0, 0, -150, 0, 0, 0, 150); // Z（青）

    // オイラー角による回転（Processingは画像座標系なので右手系に変換する）
    rotateY( Yaw[global_data_index]);   // 右手系Z
    rotateX(-Pitch[global_data_index]); //   〃　Y
    rotateZ(-Roll[global_data_index]);  //   〃　X

    object();
    popMatrix();

    // 連番画像として保存
    saveFrame("./outFrames/image_" + global_data_index + ".png");

    // データ終端に達したら終了
    global_data_index++;
    if((global_data_index + 1) > global_data_lines) {
        exit();
    }
}

// 物体を表示
void object() {
    // 重心位置
    translate(-15, 0, 0);

    pushMatrix();
    // 長い部分
    fill(63,127,255);
    rotateX(radians(90.0)); // 右手系Y
    pillar(150, 30, 30);
    popMatrix();

    pushMatrix();
    // 短い部分
    rotateY(0.0); // 右手系Z
    rotateX(0.0); //   〃　Y
    rotateZ(radians(90.0));  //   〃　X
    translate(0, -40, 0);
    fill(255, 0, 0);
    pillar(80, 20, 20);
    popMatrix();
}

// 以下のサイトのコードを利用
// peroon's diary：『processing proce55ing opengl 円柱』
//   (https://peroon.hatenablog.com/entry/20090428/1240929262)
//
// 円柱の作成
// length 長さ
// radius 上面の半径
// radius 底面の半径
void pillar(float length, float radius1 , float radius2){
    float x,y,z; //座標
    pushMatrix();

    //上面の作成
    beginShape(TRIANGLE_FAN);
    y = -length / 2;
    vertex(0, y, 0);
    for(int deg = 0; deg <= 360; deg = deg + 10){
        x = cos(radians(deg)) * radius1;
        z = sin(radians(deg)) * radius1;
        vertex(x, y, z);
    }
    endShape();

    //底面の作成
    beginShape(TRIANGLE_FAN);
    y = length / 2;
    vertex(0, y, 0);
    for(int deg = 0; deg <= 360; deg = deg + 10){
        x = cos(radians(deg)) * radius2;
        z = sin(radians(deg)) * radius2;
        vertex(x, y, z);
    }
    endShape();

    //側面の作成
    beginShape(TRIANGLE_STRIP);
    for(int deg =0; deg <= 360; deg = deg + 5){
        x = cos(radians(deg)) * radius1;
        y = -length / 2;
        z = sin(radians(deg)) * radius1;
        vertex(x, y, z);

        x = cos(radians(deg)) * radius2;
        y = length / 2;
        z = sin(radians(deg)) * radius2;
        vertex(x, y, z);
    }
    endShape();

    popMatrix();
}

// 以下のサイトのコードを利用
// 理系大学院生の知識の森：『Processingで矢印を描く方法（３次元）』
//   (https://okasho-engineer.com/processing-3d-arrow/)
void cone(int L, float radius, int Color1, int Color2, int Color3) {
    translate(0, 0, 10);  // コーンのオフセット
    float x, y;
    noStroke();
    fill(Color1, Color2, Color3);
    beginShape(TRIANGLE_FAN);  // 底面の円の作成
    vertex(0, 0, -L);
    for(float i=0; i<2*PI; i+=0.01) {
        x = radius*cos(i);
        y = radius*sin(i);
        vertex(x, y, -L);
    }

    endShape(CLOSE);
    beginShape(TRIANGLE_FAN);  // 側面の作成
    vertex(0, 0, 0);
    for(float i=0; i<2*PI; i+=0.01) {
        x = radius*cos(i);
        y = radius*sin(i);
        vertex(x, y, -L);
    }
    endShape(CLOSE);
}

// 以下のサイトのコードを利用
// 理系大学院生の知識の森：『Processingで矢印を描く方法（３次元）』
//   (https://okasho-engineer.com/processing-3d-arrow/)
void arrow(int x1, int y1, int z1, int x2, int y2, int z2, int Color1, int Color2, int Color3) {
    int arrowLength = 10;
    float arrowAngle = 0.5;
    float phi = -atan2(y2-y1, x2-x1);
    float theta = 0.5*PI - atan2(z2-z1, x2-x1);
    stroke(Color1, Color2, Color3);
    strokeWeight(4); 
    line(x1, y1, z1, x2, y2, z2);
    strokeWeight(1); 
    pushMatrix();
    translate(x2, y2, z2);
    rotateY(theta);
    rotateX(phi);
    cone(arrowLength, arrowLength*sin(arrowAngle), Color1, Color2, Color3);
    popMatrix();
}