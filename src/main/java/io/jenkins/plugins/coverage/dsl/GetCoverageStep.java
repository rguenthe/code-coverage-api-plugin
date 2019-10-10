package io.jenkins.plugins.coverage.dsl;

import hudson.Extension;
import hudson.model.Run;

import io.jenkins.plugins.coverage.CoverageAction;
import io.jenkins.plugins.coverage.targets.CoverageElement;
import io.jenkins.plugins.coverage.targets.Ratio;

import org.jenkinsci.plugins.workflow.steps.Step;
import org.jenkinsci.plugins.workflow.steps.StepContext;
import org.jenkinsci.plugins.workflow.steps.StepExecution;
import org.jenkinsci.plugins.workflow.steps.StepDescriptor;
import org.jenkinsci.plugins.workflow.steps.SynchronousStepExecution;

import org.kohsuke.stapler.DataBoundConstructor;

import java.util.HashSet;
import java.util.Set;

public class GetCoverageStep extends Step {
  
    private final String element;

    @DataBoundConstructor
    public GetCoverageStep(String element) {
        if (element != null) {
            this.element = element;
        } else {
            this.element = "Line";
        }
    }

    public String getElement() {
        return this.element;
    }

    @Override
    public StepExecution start(StepContext context) {
        return new Execution(context, this.element);
    }
  
    @Extension
    public static class DescriptorImpl extends StepDescriptor {
  
        @Override
        public String getFunctionName() {
            return "getCoverage";
        }

        @Override
        public String getDisplayName() {
            return "Get coverage results";
        }

        @Override
        public Set<Class<?>> getRequiredContext() {
            Set<Class<?>> set = new HashSet<Class<?>>();
            set.add(Run.class);
            return set;
        }
    }
  
    private static class Execution extends SynchronousStepExecution<Integer> {
        private static final long serialVersionUID = 1L;
        
        private int coverageValue = 0;
        private String element;

        Execution(StepContext context, String elem) {
            super(context);
            element = elem;
        }

        @Override
        protected Integer run() throws Exception {
            CoverageAction coverageAction = getContext().get(Run.class).getAction(CoverageAction.class);
            CoverageElement coverageElement = CoverageElement.get(element);
            if ((coverageAction != null) && (coverageElement != null)) {
                Ratio coverageRatio = coverageAction.getResult().getCoverage(coverageElement);
                if (coverageRatio != null) {
                    coverageValue = coverageRatio.getPercentage();
                }
            }
            return coverageValue;
        }
    }
}
