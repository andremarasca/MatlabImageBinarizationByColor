clear all;
close all;
clc;

imprimir = 1;
cor_escolhida = 1;

A = imread('O.png');
B = imread('B.png');

[M, N, L] = size(B);

A = double(A);

if L > 1
    B = rgb2gray(B);
end



X = zeros(M * N, 3);
Y = zeros(M * N, 1);

%% converter imagem para matriz X

u = 1;
for i = 1 : M
    for j = 1 : N
        X(u, :) = [A(i, j, 1), A(i, j, 2), A(i, j, 3)];
        if B(i, j) == 0
            Y(u) = 0;
        else
            Y(u) = 1;
        end
        u = u + 1;
    end
end

XX = bitshift(X(:, 1), 16) + bitshift(X(:, 2), 8) + X(:, 3);

[unicos, linhas] = unique(XX, 'rows');
contagem = zeros(size(unicos));

for i = 1 : length(unicos)
    for j = 1 : length(Y);
        if XX(j) == unicos(i)
            if Y(j) == 1
            contagem(i) = contagem(i) + 1;
        else
            contagem(i) = contagem(i) - 1;
        end
        end
    end
end

contagem(contagem > 0) = 1;
contagem(contagem <= 0) = 0;

X = X(linhas, :);
Y = contagem;

% cor = [Y, 0*Y, 0*Y];
% 
% scatter3(X(:,1), X(:,2), X(:,3), 2, cor, 'filled')

%% Aprendizagem

% obj = fitcdiscr(X,Y); % Fit discriminant analysis classifier

% obj = fitcnb(X,Y); % Train multiclass naive Bayes model

obj = fitcknn(X,Y,'NumNeighbors',7); % Fit k-nearest neighbor classifier

% obj = fitcsvm(X,Y); % Train binary support vector machine classifier

% obj = fitctree(X,Y); % Fit classification tree

%% Converter Imagem Teste para matriz XT

if imprimir == 1
    
    diretory1 = 'C:\Users\andre\Dropbox\Matlab\IMAGENS\Binarizacao\Testes\';
    files1 = dir([diretory1 '*.png']);
    
    for x = 1 : length(files1)
        
        E = imread([diretory1 files1(x).name]);
        [M, N, L] = size(E);
        
        %%%%%%%%%%%%%%%%%
        
        XT = zeros(M * N, 3);
        
        u = 1;
        for i = 1 : M
            for j = 1 : N
                XT(u, :) = [E(i, j, 1), E(i, j, 2), E(i, j, 3)];
                u = u + 1;
            end
        end
        
        %% Obter classificacao
        
        YT = predict(obj,XT);
        
        %%
        
        C = zeros(M, N); % minha saida
        
        u = 1;
        for i = 1 : M
            for j = 1 : N
                C(i, j) = 255 * YT(u);
                u = u + 1;
            end
        end
        
        C = uint8(C);
        %%%%%%%%%%%%%%%%%
        nome_out = sprintf('Saida/S_%s.png',files1(x).name(1:end-4));
        imwrite(uint8(C),nome_out);
        
    end
end

%% Visualizar os dados

if imprimir == 0
    
    idx = 0 : 10 : 255;
    tam = length(idx);
    
    XT = zeros(tam, 3);
    PX = zeros(tam, 1);
    PY = zeros(tam, 1);
    PZ = zeros(tam, 1);
    
    u = 1;
    for i = idx
        for j = idx
            for k = idx
                PX(u) = i;
                PY(u) = j;
                PZ(u) = k;
                XT(u, :) = [i, j, k];
                u = u + 1;
            end
        end
    end
    
    YT = predict(obj,XT);
    
    id = find(YT == cor_escolhida);
    % scatter3(PX, PY, PZ, 5, YT(:) + 1);
    scatter3(PX(id), PY(id), PZ(id), 100, YT(id) + 1, 'filled', 'MarkerEdgeColor','k');
    axis image
    
end