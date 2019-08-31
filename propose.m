function [precision, recall, duration] = propose(noise_percentage, seed)
  rng(seed);
  util   = Utility();
  solver = Solver();
  solver = solver.initialize();

  num_day      = 120;
  event_flag   = util.get_event_flag(num_day);
  clear_signal = util.get_clear_signal(event_flag);
  noise_signal = util.get_noisy_signal(clear_signal, noise_percentage);

  temporal_signal = solver.apply_temporal_condition(noise_signal);
  combined_signal = noise_signal + max(noise_signal) / max(temporal_signal) * temporal_signal;

  maxnfev = 10000;
  tic;
  solution = solver.solve(temporal_signal, combined_signal, maxnfev);
  duration = toc;
  [precision, recall] = solver.score(solution, event_flag);

  % % debug
  % fprintf('proposed_solve: %f %f\n', precision, recall);
  % subplot(1, 3, 1);
  % plot(clear_signal);
  % for i = 1:length(solution)
  %   t = solution(i);
  %   xline(t-9);
  %   xline(t+9);
  % end

  % subplot(1, 3, 2);
  % plot(noise_signal);
  % for i = 1:length(solution)
  %   t = solution(i);
  %   xline(t-9);
  %   xline(t+9);
  % end

  % subplot(1, 3, 3);
  % plot(temporal_signal);
  % for i = 1:length(solution)
  %   t = solution(i);
  %   xline(t-9);
  %   xline(t+9);
  % end

end
