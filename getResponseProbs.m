function presponse = getResponseProbs(RT,params,model)
% returns response probabilities (correct, habit, error) given RTs and
% parameters
paramsA = params(1:3);
paramsB = params(4:6);
q_i = params(7);

PhiA = normcdf(RT,paramsA(1),paramsA(2)); % probability that A has been planned by RT
PhiB = normcdf(RT,paramsB(1),paramsB(2));

qA = paramsA(3);
qB = paramsB(3);

alpha = zeros(5,4);

switch(model)
    % set up parameters:
    %     p(r) = alpha(.,1)*(1-PhiA)*(1-PhiB) + alpha(.,2)*PhiA*(1-PhiB) +
    %     alpha(.,3)*(1-PhiA)*PhiB + alpha(.,4)*PhiA*PhiB

    
    case 'habit'
        alpha(1,:) = [q_i (1-qA)/3 qB qB]; % mapping B (correct)
        alpha(2,:) = [q_i qA (1-qB)/3 (1-qB)/3]; % mapping A (habit)
        alpha(3,:) = [.5-q_i (1-qA)/3 (1-qB)/3 (1-qB)/3]; % other responses
        alpha(4,:) = [q_i qA q_i qA]; % mapping A, no-conflict
        alpha(5,:) = [q_i q_i qB qB]; % mapping B, no-conflict
        
    case 'no-habit'
        alpha(1,:) = [q_i q_i qB qB]; % mapping B (correct)
        alpha(2,:) = [q_i q_i (1-qB)/3 (1-qB)/3]; % mapping A (habit)
        alpha(3,:) = [.5-q_i .5-q_i (1-qB)/3 (1-qB)/3]; % other responses
        alpha(4,:) = [q_i qA q_i qA]; % mapping A, no-conflict
        alpha(5,:) = [q_i q_i qB qB]; % mapping B, no-conflict
        
    case 'flex-habit'
        rho = params(8);
        alpha(1,:) = [q_i rho*(1-qA)/3+(1-rho)*q_i qB qB]; % mapping B (correct)
        alpha(2,:) = [q_i rho*qA+(1-rho)*q_i (1-qB)/3 (1-qB)/3]; % mapping A (habit)
        alpha(3,:) = [.5-q_i rho*(1-qA)/3+(1-rho)*(.5-q_i) (1-qB)/3 (1-qB)/3]; % other responses
        alpha(4,:) = [q_i qA q_i qA]; % mapping A, no-conflict
        alpha(5,:) = [q_i q_i qB qB]; % mapping B, no-conflict

    otherwise disp('No such case - Use habit, no-habit, or flex-habit')
end
        
%for i=1:5
%    presponse(i,:) = alpha(i,1)*(1-PhiA).*(1-PhiB) + alpha(i,2)*PhiA.*(1-PhiB) + alpha(i,3)*(1-PhiA).*PhiB + alpha(i,4)*PhiA.*PhiB;
%end
Phi = [(1-PhiA).*(1-PhiB); PhiA.*(1-PhiB); (1-PhiA).*PhiB; PhiA.*PhiB];

presponse = alpha*Phi;