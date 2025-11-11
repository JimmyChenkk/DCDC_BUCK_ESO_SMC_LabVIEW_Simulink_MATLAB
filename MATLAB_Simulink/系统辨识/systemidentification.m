clc; clear; close all;

% ---------- 参数（请按实际修改） ----------
filename = 'systemidentification.xlsx';   % 或 'data.csv'
sheet = 1;
Ts = 1e-1;                % 采样时间 T（示例值，务必改成你的真实采样时间）
E = 16.72;                   % 电源电压 E（示例：24V），若未知见下文说明

% ---------- 导入数据 ----------
% 假设三列：iL, Vs, mu
M = readmatrix(filename); % 适用于 .xlsx/.csv
iL = M(:,1);
Vs = M(:,2);
mu = M(:,3);

% 去除 NaN / 非数值
valid = ~isnan(iL) & ~isnan(Vs) & ~isnan(mu);
iL = iL(valid); Vs = Vs(valid); mu = mu(valid);

N = length(iL);
if N < 10, error('数据长度太短'); end

% 可选：对原始信号做低通滤波以降低数值差分噪声（非常推荐）
% 下面用移动平均（窗口可调）或用低通滤波器
win = 1;                    % 窗口长度（根据采样频率与噪声调整）
iL_f = movmean(iL, win);
Vs_f = movmean(Vs, win);
mu_f = movmean(mu, win);

% 差分（向量长度变为 N-1）
di = diff(iL_f);            % iL(t)-iL(t-1)
dv = diff(Vs_f);            % Vs(t)-Vs(t-1)
mu_k = mu_f(2:end);         % 对齐到 t
Vs_k = Vs_f(2:end);
iL_k = iL_f(2:end);

% ---------- 估计 L（最小二乘） ----------
Phi_L = (di / Ts);          % (Δi)/T 列向量
Y_L   = mu_k * E - dv;      % 右端列向量
% 去掉极小的 Phi_L 以避免数值不稳定（可选）
idx = abs(Phi_L) > 1e-12;
L_est = (Phi_L(idx)\Y_L(idx));   % 标量

% ---------- 估计 C 和 alpha = 1/R（最小二乘） ----------
Phi_CR = [ (dv / Ts), Vs_k ];    % 每列分别是 Δv/T 和 Vs
Y_CR   = iL_k;
theta = Phi_CR \ Y_CR;           % [C; alpha]
C_est = theta(1);
alpha = theta(2);
R_est = 1/alpha;

% ---------- 显示结果 ----------
fprintf('辨识结果：\n');
fprintf('L = %.6g H\n', L_est);
fprintf('C = %.6g F\n', C_est);
fprintf('R = %.6g Ohm\n', R_est);

% ---------- 可选：验证拟合（绘图比较） ----------
% 使用估计参数重构右侧并比较残差
Y_L_hat = Phi_L * L_est + dv;
resid_L = (mu_k * E) - (Phi_L * L_est + dv); % 残差，理论应接近0

Y_CR_hat = Phi_CR * theta;
figure;
subplot(2,1,1);
plot(iL_k,'-'); hold on; plot(Y_CR_hat,'--'); legend('iL measured','iL estimated'); title('C,1/R模型拟合');
subplot(2,1,2);
plot(resid_L); title('L方程残差 (mu E - Δv - (Δi/T)L)');

