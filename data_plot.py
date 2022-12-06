# グラフ作成

import csv
import matplotlib.pyplot as plt
import numpy as np

t = []  # 時刻
ypr = [[], [], []]  # オイラー角
gyr = [[], [], []]  # 角速度
alpha = [[], [], []]  # 角加速度
l = [[], [], []]  # 角運動量
l_norm = []

# CSVからデータを読み出して配列に追加
with open('./result.csv') as f:
    reader = csv.reader(f)
    for row in reader:
        nums = [float(v) for v in row]

        t.append(nums[0])
        ypr[0].append(nums[1])
        ypr[1].append(nums[2])
        ypr[2].append(nums[3])
        gyr[0].append(nums[4])
        gyr[1].append(nums[5])
        gyr[2].append(nums[6])
        alpha[0].append(nums[7])
        alpha[1].append(nums[8])
        alpha[2].append(nums[9])
        l[0].append(nums[10])
        l[1].append(nums[11])
        l[2].append(nums[12])
        l_norm.append(np.sqrt(nums[10]*nums[10] + nums[11]*nums[11] + nums[12]*nums[12]))


# --- 描画 --- #
fig1 = plt.figure(figsize = (10, 9))  # 横, 縦

ax1 = fig1.add_subplot(411)
ax1.set_title('Tennis racket theorem', fontsize=20)
ax1.step(t, ypr[0], label="Yaw")
ax1.step(t, ypr[1], label="Pitch")
ax1.step(t, ypr[2], label="Roll")
ax1.set_xlim(t[0], t[-1])
ax1.set_ylabel("Euler angles\n[rad]", fontsize=12)
ax1.tick_params(labelsize=13)  # 軸目盛の大きさ
ax1.legend(fontsize=15, loc="upper right")

ax2 = fig1.add_subplot(412)
ax2.step(t, gyr[0], label="x")
ax2.step(t, gyr[1], label="y")
ax2.step(t, gyr[2], label="z")
ax2.set_xlim(t[0], t[-1])
ax2.set_ylabel("Angular rate\n[rad/s]", fontsize=12)
ax2.tick_params(labelsize=13)
ax2.legend(fontsize=15, loc="upper right")

ax3 = fig1.add_subplot(413)
ax3.step(t, alpha[0], label="x")
ax3.step(t, alpha[1], label="y")
ax3.step(t, alpha[2], label="z")
ax3.set_xlim(t[0], t[-1])
ax3.set_ylabel("Angular acceleration\n[rad/s^2]", fontsize=12)
ax3.tick_params(labelsize=13)
ax3.legend(fontsize=15, loc="upper right")

ax4 = fig1.add_subplot(414)
ax4.step(t, l[0], label="x")
ax4.step(t, l[1], label="y")
ax4.step(t, l[2], label="z")
ax4.plot(t, l_norm, label="norm", linestyle = "--")
ax4.set_xlim(t[0], t[-1])
ax4.set_xlabel("Time [s]", fontsize=15)
ax4.set_ylabel("Angular momentum\n[N*m*s]", fontsize=12)
ax4.tick_params(labelsize=13)
ax4.legend(fontsize=15, loc="upper right")

plt.show()