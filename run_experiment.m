util   = Utility();
% instances = [0.1, 0.3, 0.5, 1.0];
% instances = [0.1];
% instances = [0.3];
% instances = [0.5];
instances = [1.0];

num_seed = 30;

count = 0;
total_count = length(instances) * num_seed;
total_time = 0;
for i = 1:length(instances)
  instance = instances(i);  
  instance_name = sprintf('%0.1f', instance);
  util.mkdir('baseline', instance_name);
  util.mkdir('propose', instance_name);

  for seed = 1:num_seed
    fprintf('instance=%s algorithm=propose seed=%d', ...
      instance_name, seed)

    % % baseline
    % algorithm = 'baseline';
    % [precision, recall, duration] = baseline(0.045 * instance, seed);
    % util.save_result(precision,recall, duration, algorithm, instance_name, seed);
    % propose
    algorithm = 'propose';
    [precision, recall, duration] = propose(0.045 * instance, seed);
    util.save_result(precision,recall, duration, algorithm, instance_name, seed);

    total_time = total_time + duration;
    count = count + 1;
    fprintf(' precision=%f recall=%f elapsed=%f remain=%f\n', ...
      precision, recall, total_time, total_time * (total_count - count) / count)
  end
end