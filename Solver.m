classdef Solver

  properties
    best_objective_value;
    best_solution;
    nfev;
  end

  methods
    function obj = initialize(obj)
      obj.best_objective_value = -inf;
      obj.best_solution        = [];
      obj.nfev                 = 0;
    end

    function obj = reset_nfev(obj)
      obj.nfev = 0;
    end

    function threshold = get_threshold(obj, signal)
      threshold = mean(signal) + 3 * std(signal);
    end

    function signal = apply_threshold(obj, signal)
      threshold = obj.get_threshold(signal);
      signal(find(signal < threshold)) = 0;
    end

    function temporal_signal = apply_temporal_condition(obj, signal)
      % count number of exceed threshold in -half_period:+half_period in signal
      period = 18; % hours
      half_period = period / 2;
      T = length(signal);
      
      threshold = obj.get_threshold(signal);
      temporal_signal = zeros(1, T);
      
      for t = 1:T
        if t <= half_period
          temporal_signal(t) = sum(signal(1:t+half_period) >= threshold);
        elseif T - t <= half_period
          temporal_signal(t) = sum(signal(t-half_period:end) >= threshold);
        else
          temporal_signal(t) = sum(signal(t-half_period:t+half_period) >= threshold);
        end
      end
    end

    function candidates = get_first_candidate(obj, temporal_signal)
      interval_lb = 17*24;
      interval_ub = 24*24;

      T = length(temporal_signal);
      if T <= interval_ub
        candidates = find(temporal_signal > 0);
      else
        candidates = find(temporal_signal(1:interval_ub) > 0);
      end
      candidates = candidates(randperm(length(candidates)));
    end

    function candidates = get_kth_candidate(obj, temporal_signal, solution)
      interval_lb = 17*24;
      interval_ub = 24*24;

      T = length(temporal_signal);
      t = solution(end);
      if T - t < interval_lb
        candidates = [];
      elseif T - t < interval_ub
        candidates = find(temporal_signal(t+interval_lb:end) > 0);
        candidates = candidates + t + interval_lb - 1;
      else
        candidates = find(temporal_signal(t+interval_lb:t+interval_ub) > 0);
        candidates = candidates + t + interval_lb - 1;
      end
      candidates = candidates(randperm(length(candidates)));
    end

    function value = objective_function(obj, signal, solution)
      N = length(solution);
      value = 0;
      for i = 1:N
        % fprintf('t=%d, T=%d\n', solution(i), length(signal));
        value = value + signal(solution(i));
      end
    end

    function solution = baseline_solve(obj, temporal_signal)
      T = length(temporal_signal);
      solution = [];
      
      for t = 1:T
        if temporal_signal(t) > 0
          if length(solution) == 0
            solution = [solution, t];
          else
            prev_t = solution(end);
            if t - prev_t > 18
              solution = [solution, t];
            end
          end
        end
      end
      solution = solution + 9;
    end

    function solution = solve(obj, temporal_signal, combined_signal, maxnfev)
      candidates = obj.get_first_candidate(temporal_signal);
      for i = 1:length(candidates)
        % fprintf('iter %d/%d: best_solution=%d\n', i, length(candidates), obj.best_objective_value);
        c        = candidates(i);
        solution = [c];
        obj      = obj.reset_nfev();
        obj      = obj.solve_recursive(temporal_signal, combined_signal, solution, maxnfev);
      end
      solution = obj.best_solution;
    end

    function obj = solve_recursive(obj, temporal_signal, signal, solution, maxnfev)
      % evaluate and update best solution
      objective_value = obj.objective_function(signal, solution);
      if objective_value > obj.best_objective_value
        obj.best_objective_value = objective_value;
        obj.best_solution        = solution;
        % fprintf('found best solution (value=%f, nfev=%d)\n', objective_value, obj.nfev);
        % obj.best_solution
      end
      obj.nfev = obj.nfev + 1;

      % recursive find
      candidates = obj.get_kth_candidate(temporal_signal, solution);
      if length(candidates) >= 1
        for i = 1:length(candidates)
          solution = [solution, candidates(i)];
          obj = obj.solve_recursive(temporal_signal, signal, solution, maxnfev);
          solution = solution(1:end-1);
          % stopping condition
          if obj.nfev > maxnfev, break; end
        end
      end
    end

    function [precision, recall] = score(obj, solution, event_flag)
      T = length(event_flag);
      solution_flag = zeros(1, T);

      for i = 1:length(solution)
        t = solution(i);
        for j = t-9:t+9
          if j < T
            solution_flag(j) = 1;
          end
        end
      end
      solution_flag = solution_flag(1: T);
      union_flag = and(event_flag, solution_flag);

      num_union = 0;
      for t = 1:T-1
        if union_flag(t) == 0 && union_flag(t+1) == 1
          num_union = num_union + 1;
        end
      end

      num_event = 0;

      for t = 1:T-1
        if event_flag(t) == 0 && event_flag(t+1) == 1
          num_event = num_event + 1;
        end
      end

      precision  = num_union / length(solution);
      recall     = num_union / num_event;

    end

  end
end
