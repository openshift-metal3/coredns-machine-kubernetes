package object

import (
	machineapi "github.com/openshift/cluster-api/pkg/apis/machine/v1beta1"
	"k8s.io/apimachinery/pkg/runtime"
)

// Machine is a stripped down machineapi.Machine with only the items we need for CoreDNS.
type Machine struct {
	Version     string
	MachineIP   string
	Name        string
	Namespace   string
	ClusterName string
	Deleting    bool

	*Empty
}

var _ runtime.Object = &Machine{}

// ToMachine converts a machineapi.Machine to a *Machine
func ToMachine(obj interface{}) interface{} {
	machine, ok := obj.(*machineapi.Machine)
	if !ok {
		return nil
	}

	m := &Machine{
		Version:     machine.GetResourceVersion(),
		MachineIP:   machine.Status.Addresses[0].Address,
		Name:        machine.ObjectMeta.GetName(),
		Namespace:   machine.GetNamespace(),
		ClusterName: machine.ObjectMeta.GetClusterName(),
	}
	t := machine.ObjectMeta.DeletionTimestamp
	if t != nil {
		m.Deleting = !(*t).Time.IsZero()
	}

	*machine = machineapi.Machine{}

	return m
}

// DeepCopyObject implements the ObjectKind interface.
func (m *Machine) DeepCopyObject() runtime.Object {
	m1 := &Machine{
		Version:     m.Version,
		MachineIP:   m.MachineIP,
		Name:        m.Name,
		Namespace:   m.Namespace,
		ClusterName: m.ClusterName,
		Deleting:    m.Deleting,
	}
	return m1
}

// GetNamespace implements the metav1.Object interface.
func (m *Machine) GetNamespace() string { return m.Namespace }

// SetNamespace implements the metav1.Object interface.
func (m *Machine) SetNamespace(namespace string) {}

// GetName implements the metav1.Object interface.
func (m *Machine) GetName() string { return m.Name }

// SetName implements the metav1.Object interface.
func (m *Machine) SetName(name string) {}

// GetResourceVersion implements the metav1.Object interface.
func (m *Machine) GetResourceVersion() string { return m.Version }

// SetResourceVersion implements the metav1.Object interface.
func (m *Machine) SetResourceVersion(version string) {}
