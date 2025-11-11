% 读取数据
data = readmatrix('VSM025Acvrt.xlsx');
x = data(:,5);
y = data(:,6);

% ====== 数据筛选 ======
mask = (x >= 0.1) & (y >= 0.5) & (y <= 6) & ~((x <= 1.1) & (y >= 4.5));
x = x(mask);
y = y(mask);

% 拟合计算
X = [x ones(size(x))];      % 构造 [x 1] 矩阵
coef = X \ y;               % 最小二乘解
a = coef(1);
b = coef(2);

fprintf('拟合结果: y = %.4f * x + %.4f\n', a, b);

% 绘制散点图
figure;
scatter(x, y, 40, 'b', 'filled');     % 原始数据点
hold on;

% 绘制拟合直线
x_fit = linspace(min(x), max(x), 200);   % 在范围内生成均匀点
y_fit = a * x_fit + b;
plot(x_fit, y_fit, 'r', 'LineWidth', 2);

% 图形修饰
xlabel('x');
ylabel('y');
title('线性拟合结果（剔除x或y<1.1的数据）');
legend('保留数据点', sprintf('拟合线: y = %.4f x + %.4f', a, b), 'Location', 'best');
grid on;
hold off;
